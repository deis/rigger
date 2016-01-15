function sanitize-variable {
  # introduced for v1.11.0 secret leakage

  local variable="${1}"
  local force="${2:-false}"

  local blacklist="AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DO_TOKEN
DO_SSH_FINGERPRINT"

  if echo "${blacklist}" | grep -s "${variable}" &> /dev/null || \
    [ ${force} == true ]; then
    echo "******"
  else
    echo "${!variable}"
  fi
}

function skip-prompt-if-set {
  local variable="${1}"
  local sanitize="${2:-false}"

  if [ ! -z ${!variable:-} ]; then
    rerun_log warn "${variable} already set to $(sanitize-variable ${variable} ${sanitize}). Skipping prompt."
    return 1
  else
    return 0
  fi
}

function choice-prompt {
  local question="${1}"
  local options=("${!2}")
  local default="${3:-1}"
  local return_var="${4:-answer}"

  local default_text="${options[$(expr ${default} - 1)]}"

  skip-prompt-if-set ${return_var} || return 0

  local input
  while [ -z "${input:-}" ]; do

    # prompt
    rerun_log "-> ${question} ${return_var} [ ${default_text} ]"

    for ((i=0; i < ${#options[@]}; i++))
    do
      echo "$(expr ${i} + 1)) ${options[$i]}"
    done

    echo -n "#? "

    # answer
    read input

    if [ -z "${input}" ]; then
      input="${default}"
    fi

    if [[ ${input:-} -le ${#options[@]} ]]; then
      eval "${return_var}=${input}"
      rerun_log warn "You chose: ${input}) ${options[$(expr ${!return_var} - 1)]}"
    else
      rerun_log warn "You chose: ${input}) which is invalid."
      input=""
    fi
  done
}

function password-prompt {
  local question="${1}"
  local return_var="${2}"
  local default="${3:-}"

  skip-prompt-if-set "${return_var}" true || return 0

  local input

  while [ -z "${input:-}" ]; do

    if [ -z ${default} ]; then
      rerun_log "-> ${question} ${return_var} (no default)"
    else
      rerun_log "-> ${question} ${return_var} [ ****** ]"
    fi

    read -s input

    [ -n "${default}" ] && break

  done

  eval "export ${return_var}=${input:-${default}}"

  save-secrets "${return_var}"

  echo "You chose: ******"
}

function prompt {
  local question="${1}"
  local return_var="${2}"
  local default="${3:-}"

  skip-prompt-if-set ${return_var} || return 0

  local input

  while [ -z "${input:-}" ]; do

    if [ -z ${default} ]; then
      rerun_log "-> ${question} ${return_var} (no default)"
    else
      rerun_log "-> ${question} ${return_var} [ ${default} ]"
    fi

    read input

    [ -n "${default}" ] && break

  done

  eval "export ${return_var}=${input:-${default}}"

  echo "You chose: $(sanitize-variable ${return_var})"
}

function index-of {
  local search_for="${1}"
  shift
  local list="${@}"

  local element
  local i=0
  for element in ${list}; do
    if [[ "${element}" == "${search_for}" ]]; then
      echo "${i}"
      return 0
    fi
    let i++
  done
  echo "-1"
}

function list-private-keys {
  find "${HOME}/.ssh" -type f -exec grep -l 'PRIVATE KEY[-]*$' {} \;
}

function ssh-private-key-prompt {
  local question="${1-"Which private SSH key should be used?"}"
  local return_var="${2:-SSH_PRIVATE_KEY_FILE}"
  local default="${3:-}"

  skip-prompt-if-set ${return_var} || return 0

  while [ -z "$(list-private-keys)" ]; do
    rerun_log error "You don't have any ssh keypairs for rigger to use. Let's create one!"
    ssh-keygen -t rsa -b 4096 1>&2
  done

  local options=($(list-private-keys))

  if [ ! -z ${default} ]; then
    default=$(index-of "${default}" ${options[@]})
    if [ ${default} -ge 0 ]; then
      let default+=1
    else
      default=1
    fi
  else
    default=1
  fi

  choice-prompt "${question}" options[@] ${default} ${return_var}
  eval "export ${return_var}=${options[$(expr ${!return_var} - 1)]}"
  save-vars "${return_var}"
}
