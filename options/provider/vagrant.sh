SUGGEST_DEIS_TEST_DOMAIN="local3.deisapp.com"
SUGGEST_DEIS_SSH_KEY="${HOME}/.vagrant.d/insecure_private_key"

function _setup-provider-dependencies {
  :
}

function _destroy-all-vagrants {
  VMS=$(vagrant global-status | grep deis | awk '{ print $5 }')
  for dir in $VMS; do
    cd $dir && vagrant destroy --force
  done
}

function _create {
  rerun_log "Creating Vagrant cluster..."

  {
    cd ${DEIS_ROOT}
    vagrant up --provider virtualbox
  }

  export DEISCTL_TUNNEL="${DEISCTL_TUNNEL:-127.0.0.1:2222}"
  save-var DEISCTL_TUNNEL
}

function _destroy {
  rerun_log "Destroying Vagrant cluster..."
  _destroy-all-vagrants
}
