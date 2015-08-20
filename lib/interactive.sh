function choice-prompt {
  local question="${1}"
  local options=("${!2}")
  local default="${3:-1}"
  local return_var="${4}"

  local default_text="${options[$(expr ${default} - 1)]}"

  rerun_log "-> ${question} [ ${default_text} ]"

  for ((i=0; i < ${#options[@]}; i++))
  do
    echo "$(expr ${i} + 1)) ${options[$i]}"
  done

  echo -n "#? "

  read input

  eval ${return_var}=${input:-${default}}

  echo "You chose: ${!return_var}) ${options[$(expr ${!return_var} - 1)]}"
}

function prompt {
  local question="${1}"
  local default="${2}"
  local return_var="${3}"

  if [ -z "${!return_var:-}" ]; then

    rerun_log "-> ${question} [ ${default} ]"

    read input

    eval ${return_var}=${input:-${default}}

    echo "You chose: ${!return_var}"
  fi
}
