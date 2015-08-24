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

function check-registry {
  if ! curl -s $DEV_REGISTRY 1> /dev/null && ! curl -s https://$DEV_REGISTRY 1> /dev/null; then
    rerun_log error "DEV_REGISTRY is not accessible, exiting..."
    exit 1
  fi
}

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

function source-defaults {
  source "config/defaults.sh"
}

function source-config {
  source "config/deis-defaults.sh"
}

function setup-provider-dependencies {
  _setup-provider-dependencies
}

function destroy-cluster {
  local force="${1:-}"

  if [[ ${CLEANUP:-} == true ]] || [[ ${force} == true ]]; then
    rerun_log "Cleaning up"
    _destroy || true
  fi
}

function create-cluster {
  save-var PROVIDER
  _create
}

function echo-export {
  local variable="${1}"

  eval "export ${variable}=\"${!variable}\""
  echo "export ${variable}=\"${!variable}\""
}

function load-env {
  source "${DEIS_TEST_ENV}"
}

function update-link {
  local file="${1}"

  if [ -f "${file}" ]; then
    rerun_log debug "Linking ${DEIS_TEST_ENV} to ${file}"
    ln -fs "${file}" "${DEIS_TEST_ENV}"
  else
    rerun_die "${file} does not exist."
  fi
}

function is-released-version {
  [[ ${1} =~ ^([0-9]+\.){0,2}[0-9]$ ]] && return 0
}

function save-env {
  local vars_to_save="${1:-}"
  vars_to_save+=" DEIS_VARS_FILE
                  DEIS_TEST_ID
                  ORIGINAL_PATH
                  PATH
                  DEIS_TEST_ROOT
                  VERSION"

  mkdir -p "${DEIS_TEST_ROOT}"
  cat /dev/null > "${DEIS_VARS_FILE}"

  for var in ${vars_to_save}; do
    if [ -z "${!var:-}" ]; then
      rerun_log debug "${var} is null, therefore not writing to ${DEIS_VARS_FILE}"
    else
      save-var "${var}"
    fi
  done

  sort -u "${DEIS_VARS_FILE}" -o "${DEIS_VARS_FILE}"
  update-link "${DEIS_VARS_FILE}"
}

function save-var {
  local var="${1}"

  if [ -n "${var:-}" ]; then
    sed -ie "/^export ${var}=.*$/d" ${DEIS_VARS_FILE}
    echo-export "${var}" >> "${DEIS_VARS_FILE}"
    sort -u "${DEIS_VARS_FILE}" -o "${DEIS_VARS_FILE}"
  fi
}

function setup-test-hacks {
  # install required go dependencies
  go get -v github.com/golang/lint/golint
  go get -v github.com/tools/godep

  export GIT_SSH="${DEIS_ROOT}/tests/bin/git-ssh-nokeycheck.sh"

  # cleanup any stale example applications
  rm -rf ${DEIS_ROOT}/tests/example-*

  # generate ssh keys if they don't already exist
  if [ ! -f ${HOME}/.ssh/${DEIS_TEST_AUTH_KEY} ]; then
    ssh-keygen -t rsa -f ~/.ssh/${DEIS_TEST_AUTH_KEY} -N ''
  fi

  if [ ! -f ${HOME}/.ssh/deiskey ]; then
    ssh-keygen -q -t rsa -f ~/.ssh/deiskey -N '' -C deiskey
  fi

  # prepare the SSH agent
  ssh-add -D 2> /dev/null || eval $(ssh-agent) && ssh-add -D 2> /dev/null
  ssh-add ${HOME}/.ssh/$DEIS_TEST_AUTH_KEY 2> /dev/null
  ssh-add $DEIS_TEST_SSH_KEY 2> /dev/null

  # clear the drink of choice in case the user has set it
  unset DEIS_DRINK_OF_CHOICE
}

source-shared
