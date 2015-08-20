function setup-clients {
  local version="${1}"

  rerun_log "Installing clients (version: ${version})"
  
  setup-deis-client "${version}"
  setup-deisctl-client "${version}"

  export PATH="${DEIS_BIN_DIR}:${PATH}"
  save-var PATH
}

function download-client {
  local client="${1}"
  local version="${2}"
  local dir="${3}"

  {
    mkdir -p "${dir}"
    cd "${dir}"
    curl -sSL "http://deis.io/${client}/install.sh" | sh -s "${version}"
  }
}

function setup-go-dependencies {
  go get -v github.com/golang/lint/golint
  go get -v github.com/tools/godep
}

function build-deis-client {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deis-cli locally at ${dir} ..."

  {
    cd "${dir}"

    update-repo "${dir}" "${version}"

    setup-go-dependencies
    make -C client build

    rerun_log "Installing deis-cli at ${DEISCLI_BIN}"

    mkdir -p "${DEIS_BIN_DIR}"
    cp "client/dist/deis" ${DEISCLI_BIN}

  }
}

function setup-deis-client {
  local version="${1}"

  # give this session a unique ~/.deis/<client>.json file
  export DEIS_PROFILE="test-${DEIS_TEST_ID}"
  rm -f $HOME/.deis/test-${DEIS_TEST_ID}.json

  rerun_log "Installing deis-cli (${version}) at ${DEISCLI_BIN}..."

  if is-released-version "${version}" ; then
    download-client "deis-cli" "${version}" "${DEIS_BIN_DIR}"
  else
    build-deis-client "${version}" "${DEIS_ROOT}"
  fi

  save-var DEIS_PROFILE
}

function build-deisctl {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deisctl locally at ${dir} ..."

  {
    cd "${dir}"

    setup-go-dependencies
    update-repo "${dir}" "${version}"
    make -C deisctl build

    rerun_log "Installing deisctl at ${DEISCTL_BIN}"
    mkdir -p "${DEISCTL_UNITS}"
    cp "deisctl/deisctl" "${DEISCTL_BIN}"
    cp -r deisctl/units/* "${DEISCTL_UNITS}"
  }
}

function setup-deisctl-client {
  local version="${1}"

  if is-released-version "${version}" ; then
    download-client "deisctl" "${version}" "${DEIS_BIN_DIR}"

    rerun_log "Moving unit files to ${DEISCTL_UNITS}"
    mkdir -p "${DEISCTL_UNITS}"
    mv ${HOME}/.deis/units/* ${DEISCTL_UNITS}
  else
    build-deisctl "${version}" "${DEIS_ROOT}"
  fi

  save-var DEISCTL_UNITS
}

function update-repo {
  local dir="${1}"
  local version="${2}"

  {
    cd "${dir}"
    git fetch
    git checkout "${version}"
  }
}