# Shell functions for the tests module.
#/ usage: source RERUN_MODULE_DIR/lib/functions.sh command
#

# Read rerun's public functions
. $RERUN || {
    echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
    return 1
}

[[ $# = 1 ]] || rerun_option_usage

#
if [[ -r $RERUN_MODULE_DIR/commands/$1/options.sh ]] 
then
    . $RERUN_MODULE_DIR/commands/$1/options.sh || {
        rerun_die "Failed loading options parser."
    }
fi

function install-bin-deps {
  export PATH="${EXTERNAL_BIN_DIR}:${PATH}"
  save-vars PATH

  install-jq
}

function check-registry {
  if ! curl -s "${DEV_REGISTRY}" 1> /dev/null && ! curl -s "https://${DEV_REGISTRY}" 1> /dev/null; then
    rerun_log error "DEV_REGISTRY is not accessible, exiting..."
    exit 1
  fi
}

function check-docker {
  if ! docker ps; then
    rerun_log error "Docker is not available to the build process. Exiting."
    exit 1
  fi
}

function setup-provider {
# This loads the provider's implementations of the provider interface
  source "providers/interface.sh"
  save-vars PROVIDER
}

function configure-provider {
  _configure
}

function setup-upgrader {
  local upgrader="${1}"

  source "${UPGRADER_DIR}/interface.sh"
  source "${UPGRADER_DIR}/${upgrader}.sh"
}

function render-shell-template {
  local command=$(echo -e "cat <<TEMPLATE
$(< "${1}")
TEMPLATE
")
  eval "${command}"
}

function source-shared {
  while read file; do
    source "${file}"
  done < <(find ${RERUN_MODULE_DIR}/lib -name *.sh | grep -v functions.sh)
}

function source-defaults {
  source "config/defaults.sh"

  install-bin-deps
}

function source-config {
  source "config/deis-defaults.sh"
}

function setup-provider-dependencies {
  _setup-provider-dependencies
}

function destroy-cluster {
  _destroy
}

function create-cluster {
  _create
}

function echo-export {
  local variable="${1}"

  eval "export ${variable}=\"${!variable}\""
  echo "export ${variable}=\"${!variable}\""
}

function load-secrets {
  if [ -f "${RIGGER_SECRETS_FILE}" ]; then
    source "${RIGGER_SECRETS_FILE}"
  fi
}

function load-env {
  local environment="${1:-${RIGGER_CURRENT_ENV}}"

  load-secrets

  if [ -f "${environment}" ]; then
    rerun_log debug "Sourcing ${environment}"
    source "${environment}"
  else
    rerun_log fatal "${environment} doesn't exist. Have you run rigger configure yet?"
    exit 1
  fi
}

function unload-env {
  local environment="${1:-${RIGGER_CURRENT_ENV}}"

  if [ -f "${environment}" ]; then
    rerun_log debug "Unsetting all variables in ${environment}"
    local var
    echo "unset $(cat "${environment}" | grep -v 'export PATH' \
          | awk '{print $2}' \
          | cut -s -d = -f 1 | xargs)"
  fi
}

function update-link {
  local file="${1}"

  if [ -f "${file}" ]; then
    rerun_log debug "Linking ${RIGGER_CURRENT_ENV} to ${file}"
    ln -fs "${file}" "${RIGGER_CURRENT_ENV}"
  else
    rerun_die "${file} does not exist."
  fi
}

function save-secrets {
  rigger-save-vars -f "${RIGGER_SECRETS_FILE}" ${@}
  chmod 600 "${RIGGER_SECRETS_FILE}"
}

function save-vars {
  rigger-save-vars -f "${RIGGER_VARS_FILE}" ${@}
}

function setup-test-hacks {
  # cleanup any stale example applications
  rm -rf ${DEIS_ROOT}/tests/example-*

  setup-go-dependencies

  # clear the drink of choice in case the user has set it
  unset DEIS_DRINK_OF_CHOICE
}

function rigger {
  ${RIGGER_ROOT}/rigger ${@}
}

source-shared
