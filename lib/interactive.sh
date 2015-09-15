function choice-prompt {
  local question="${1}"
  local options=("${!2}")
  local default="${3:-1}"
  local return_var="${4}"

  local default_text="${options[$(expr ${default} - 1)]}"

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

function prompt {
  local question="${1}"
  local return_var="${2}"
  local default="${3:-}"

  if [ -z "${!return_var:-}" ]; then

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

    echo "You chose: ${!return_var}"

  fi
}
