function ssh-fingerprint {
  local private_key_file="${1}"

  local sshkeygen_string="ssh-keygen -lf"

  set +o pipefail
  if ssh-keygen - 2>&1 | grep -q "\-E"; then
    sshkeygen_string="ssh-keygen -E md5 -lf"
  fi
  set -o pipefail

  local fingerprint="$(${sshkeygen_string} "${private_key_file}" 2>/dev/null \
                          | awk '{ print $2 }' \
                          | sed s/MD5://)"

  if [ $? -ne 0 ]; then
    return 1
  else
    echo "${fingerprint}"
  fi
}

function ensure-ssh-keys-loaded {
  rerun_log "Ensuring ssh keys are being served by ssh-agent..."

  local keys="$(echo ${@} | tr ' ' '\n' | uniq)"

  for key in ${keys}; do
    if ! ssh-add -L | grep -q "${key}"; then
      ssh-add "${key}" 2> /dev/null
    fi
  done
}

function setup-ssh-agent {
  # generate ssh keys if they don't already exist
  if [ ! -f "${DEIS_TEST_AUTH_KEY_FULL}" ]; then
    ssh-keygen -t rsa -f "${DEIS_TEST_AUTH_KEY_FULL}" -N ''
  fi

  if [ ! -f ${HOME}/.ssh/deiskey ]; then
    ssh-keygen -q -t rsa -f ~/.ssh/deiskey -N '' -C deiskey
  fi

  # prepare the SSH agent
  if [ -z ${SSH_AGENT_PID:-} ]; then
    rerun_log "Starting ssh-agent..."
    eval $(ssh-agent) 2> /dev/null
  fi

  ensure-ssh-keys-loaded "${DEIS_TEST_SSH_KEY}" "${DEIS_TEST_AUTH_KEY_FULL}"

  export GIT_SSH="${DEIS_ROOT}/tests/bin/git-ssh-nokeycheck.sh"

  save-vars SSH_AUTH_SOCK SSH_AGENT_PID
}
