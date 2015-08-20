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

  export DEIS_TEST_SSH_KEY="${DEIS_TEST_SSH_KEY:-${HOME}/.vagrant.d/insecure_private_key}"
  export DEIS_TEST_DOMAIN="${DEIS_TEST_DOMAIN:-local3.deisapp.com}"
  export DEISCTL_TUNNEL="${DEISCTL_TUNNEL:-127.0.0.1:2222}"
  save-var DEIS_TEST_SSH_KEY
  save-var DEIS_TEST_DOMAIN
  save-var DEISCTL_TUNNEL

  {
    cd ${DEIS_ROOT}
    vagrant up --provider virtualbox
  }
}

function _destroy {
  rerun_log "Destroying Vagrant cluster..."
  _destroy-all-vagrants
}
