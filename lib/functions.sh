# Shell functions for the tests module.
#/ usage: source RERUN_MODULE_DIR/lib/functions.sh command
#

# Read rerun's public functions
. $RERUN || {
    echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
    return 1
}

# Check usage. Argument should be command name.
[[ $# = 1 ]] || rerun_option_usage

# Source the option parser script.
#
if [[ -r $RERUN_MODULE_DIR/commands/$1/options.sh ]] 
then
    . $RERUN_MODULE_DIR/commands/$1/options.sh || {
        rerun_die "Failed loading options parser."
    }
fi

# - - -
# Your functions declared here.
# - - -

function not-implemented {
  rerun_log "No implementation of ${FUNCNAME[1]} in ${PROVIDER}"
}

function setup-provider {
# This loads the provider's implementations of the provider interface
  local provider="${1}"

  source "${PROVIDER_DIR}/interface.sh"
  source "${PROVIDER_DIR}/${provider}.sh"
}

function setup-upgrader {
  local upgrader="${1}"

  source "${UPGRADER_DIR}/interface.sh"
  source "${UPGRADER_DIR}/${upgrader}.sh"
}

function source-shared {
  while read file; do
    source "${file}"
  done < <(find ${RERUN_MODULE_DIR}/lib -name *.sh | grep -v functions.sh)
}

function source-config {
  while read file; do
    source "${file}"
  done < <(find ${RERUN_MODULE_DIR}/config -name *.sh)
}

function setup-provider-dependencies {
  _setup-provider-dependencies
}

function destroy-cluster {
  dump-vars

  if [ "${SKIP_CLEANUP}" != true ]; then
    rerun_log "Cleaning up"
    _destroy || true
  fi
}

function create-cluster {
  _create
}

function echo-export {
  local variable="${1}"

  echo "export ${variable}=\"${!variable}\""
}

function load-env {
  source "/tmp/deis/vars"
}

function update-link {
  local id="${1}"

  ln -fs "/tmp/deis/${DEIS_TEST_ID}/vars" /tmp/deis/vars
}

function save-env {
  mkdir -p "${TEST_ROOT}"
  cat /dev/null > ${TEST_ROOT}/vars

  local vars="DEIS_TEST_ID
              DEV_REGISTRY
              DEISCTL_TUNNEL
              DEISCTL_UNITS
              DEIS_ROOT
              DEIS_TEST_APP
              DEIS_TEST_AUTH_KEY
              DEIS_TEST_DOMAIN
              DEIS_TEST_SSH_KEY
              HOST_IPADDR
              PATH
              TEST_ROOT
              VERSION"

  for var in ${vars}; do
    echo-export "${var}" >> ${TEST_ROOT}/vars
  done

  update-link "${DEIS_TEST_ID}"
}

source-shared
