function setup-clients {
  local version="${1}"

  setup-deis-client "${version}"
  setup-deisctl-client "${version}"

  export PATH="${DEIS_BIN_DIR}:${PATH}"
  save-vars PATH
}

function download-client {
  local client="${1}"
  local version="${2}"
  local dir="${3}"

  mkdir -p "${dir}"
  (
    cd "${dir}"
    curl -sSL "http://deis.io/${client}/install.sh" | sh -s "${version}"
  )
}

function setup-go-dependencies {
  go get -v github.com/golang/lint/golint
  go get -v github.com/tools/godep
}

function build-deis-client {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deis-cli locally at ${dir} ..."

  (
    cd "${dir}"

    setup-go-dependencies
    make -C client build

    rerun_log "Installing deis-cli at ${DEISCLI_BIN}"

    mkdir -p "${DEIS_ID_DIR}/${version}"
    if [ -f client/dist/deis ]; then # old client
      cp "client/dist/deis" "${DEIS_ID_DIR}/${version}/deis"
    elif [ -f client/deis ]; then
      cp "client/deis" "${DEIS_ID_DIR}/${version}/deis"
    else
      rerun_die "No client available"
    fi
  )
}

function setup-deis-client {
  local version="${1}"

  # give this session a unique ~/.deis/<client>.json file
  export DEIS_PROFILE="test-${DEIS_ID}"
  rm -f $HOME/.deis/test-${DEIS_ID}.json

  rerun_log "Installing deis-cli (${version}) at ${DEISCLI_BIN}..."

  if [ -z "${BUILD_TYPE:-}" ]; then
    download-client "deis-cli" "${version}" "${DEIS_ID_DIR}/${version}"
  else
    build-deis-client "${version}" "${DEIS_ROOT}"
  fi

  link-client "${DEISCLI_BIN}" "${DEIS_ID_DIR}/${version}/deis" 

  save-vars DEIS_PROFILE
}

function move-units {
  local version="${1}"

  rerun_log "Moving unit files to ${DEISCTL_UNITS}"
  rm -rf "${DEIS_ID_DIR}/${version}/units"
  mkdir -p "${DEIS_ID_DIR}/${version}/units"
  mv ${HOME}/.deis/units/* "${DEIS_ID_DIR}/${version}/units/"
}

function link-client {
  local link="${1}"
  local file="${2}"

  rerun_log "Linking ${link} -> ${file}"
  mkdir -p "$(dirname ${link})"
  ln -sf "${file}" "${link}"
}

function link-units {
  rerun_log "Linking ${DEISCTL_UNITS} -> ${DEIS_ID_DIR}/${version}/units"
  ln -sf "${DEIS_ID_DIR}/${version}/units" "${DEISCTL_UNITS}"
}

function build-deisctl {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deisctl locally at ${dir} ..."

  (
    cd "${dir}"

    setup-go-dependencies
    make -C deisctl build

    rerun_log "Installing deisctl at ${DEISCTL_BIN}"
    mkdir -p "${DEIS_ID_DIR}/${version}/units"
    cp "deisctl/deisctl" "${DEIS_ID_DIR}/${version}/deisctl"
    cp -r deisctl/units/* "${DEIS_ID_DIR}/${version}/units"
  )
}

function setup-deisctl-client {
  local version="${1}"

  if [ -z "${BUILD_TYPE:-}" ]; then
    download-client "deisctl" "${version}" "${DEIS_ID_DIR}/${version}"
    move-units "${version}"
  else
    build-deisctl "${version}" "${DEIS_ROOT}"
  fi

  link-client "${DEISCTL_BIN}" "${DEIS_ID_DIR}/${version}/deisctl"
  link-units
}

function update-repo {
  local dir="${1}"
  local version="${2}"

  (
    cd "${dir}"
    git fetch
    git checkout "${version}"
  )
}