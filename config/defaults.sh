export RIGGER_HOME="${HOME}/.rigger"

export UPGRADER_DIR="${RIGGER_ROOT}/options/upgrade-style"

export RIGGER_CURRENT_ENV="${RIGGER_HOME}/vars"

export TERRAFORM_DIR="${RIGGER_HOME}/terraform"

export DEIS_ID=${DEIS_ID:-$(openssl rand -hex 5)}
export DEIS_ID_DIR="${RIGGER_HOME}/${DEIS_ID}"
export RIGGER_VARS_FILE="${DEIS_ID_DIR}/vars"

export SUGGEST_DEV_REGISTRY="registry.hub.docker.com"
export SUGGEST_GOPATH="${HOME}/go"
export SUGGEST_DEIS_GIT_REPO="https://github.com/deis/deis.git"
export SUGGEST_DEIS_GIT_VERSION="master"

export DEIS_BIN_DIR="${RIGGER_HOME}/bin"
export DEISCLI_BIN="${DEIS_BIN_DIR}/deis"
export DEISCTL_BIN="${DEIS_BIN_DIR}/deisctl"
export DEISCTL_UNITS="${RIGGER_HOME}/units"

export PATH="${RIGGER_ROOT}/bin:${PATH}"
