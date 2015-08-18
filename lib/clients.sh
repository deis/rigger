function setup-clients {
  local version="${1}"

  rerun_log "Installing clients (version: ${version})"

  setup-deis-client "${version}"
  setup-deisctl-client "${version}"
}

function is-released-version {
  [[ ${1} =~ ^([0-9]+\.){0,2}[0-9]$ ]] && return 0
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

function build-deis-client {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deis-cli locally at ${dir} ..."

  {
    cd "${dir}"

    update-repo "${dir}" "${version}"
    make -C client build

    rerun_log "Installing deis-cli at ${DEISCLI_BIN}"

    mkdir -p "${DEIS_BIN_DIR}"
    cp "client/dist/deis" ${DEISCLI_BIN}

  }
}

function setup-deis-client {
  local version="${1}"

  rerun_log "Installing deis-cli (${version}) at ${DEISCLI_BIN}..."

  if is-released-version "${version}" ; then
    download-client "deis-cli" "${version}" "${DEIS_BIN_DIR}"
  else
    build-deis-client "${version}" "${PROJECT_DIR}"
  fi

}

function build-deisctl {
  local version="${1}"
  local dir="${2}"

  rerun_log "Building deisctl locally at ${dir} ..."

  {
    cd "${dir}"

    update-repo "${dir}" "${version}"
    make -C deisctl build

    rerun_log "Installing deisctl at ${DEISCTL_BIN}"
    mkdir -p "${DEISCTL_UNITS_DIR}"
    cp "deisctl/deisctl" "${DEISCTL_BIN}"
    cp -r deisctl/units/* "${DEISCTL_UNITS_DIR}"

  }
}

function setup-deisctl-client {
  local version="${1}"

  unset DEISCTL_UNITS

  if is-released-version "${version}" ; then
    download-client "deisctl" "${version}" "${DEIS_BIN_DIR}"

    rerun_log "Moving unit files to ${DEISCTL_UNITS_DIR}"
    mkdir -p "${DEISCTL_UNITS_DIR}"
    mv ${HOME}/.deis/units/* ${DEISCTL_UNITS_DIR}
  else
    build-deisctl "${version}" "${PROJECT_DIR}"
  fi
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