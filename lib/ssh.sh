function ssh-fingerprint {
  local private_key_file="${1}"

  local sshkeygen_string="ssh-keygen -lf"

  if ssh-keygen - 2>&1 | grep -q "\-E"; then
    sshkeygen_string="ssh-keygen -E md5 -lf"
  fi

  local fingerprint="$(${sshkeygen_string} "${private_key_file}" 2>/dev/null \
                          | awk '{ print $2 }' \
                          | sed s/MD5://)"

  if [ $? -ne 0 ]; then
    return 1
  else
    echo "${fingerprint}"
  fi
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
  if [ -z ${SSH_AGENT_PID} ]; then
    rerun_log "Starting ssh-agent..."
    ssh-add -D 2> /dev/null || eval $(ssh-agent) && ssh-add -D 2> /dev/null
  fi

  rerun_log "Ensuring ssh keys are being served by ssh-agent..."
  ssh-add "${DEIS_TEST_AUTH_KEY_FULL}" 2> /dev/null
  ssh-add "${DEIS_TEST_SSH_KEY}" 2> /dev/null

  export GIT_SSH="${DEIS_ROOT}/tests/bin/git-ssh-nokeycheck.sh"
}
