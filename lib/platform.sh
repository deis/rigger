function checkout-deis {
  local dir="${1}"
  local version="${2}"

  if is-released-version "${version}"; then
    version="v${version}"
  fi

  if [ -d "${dir}/.git" ]; then
    rerun_log "Updating Deis at ${dir} to ${version}"
    (
      cd "${dir}"
      git fetch
      git fetch --tags
      git checkout ${version}
      git pull origin ${version}
    )
  else
    rerun_log "Cloning Deis at ${dir} to ${version}"
    git clone --depth 1 -b "${version}" https://github.com/deis/deis.git "${dir}"
  fi
}

function build-deis {
  local version="${1}"

  if [[ ${BUILD_TYPE:-} -ne 1 ]]; then # client-only build
    deisctl config platform set version="v${version}"
  else
    check-registry
    (
      setup-go-dependencies
      cd "${DEIS_ROOT}"
      make build dev-release
    )
  fi
}

function deploy-deis {
  local version="${1}"

  check-etcd-alive

  deisctl config platform set domain="${DEIS_TEST_DOMAIN}"
  deisctl config platform set sshPrivateKey="${DEIS_TEST_SSH_KEY}"

  build-deis "${version}"

  deisctl install platform
  deisctl start platform

  _check-cluster
}

function undeploy-deis {
  deisctl stop platform
  deisctl uninstall platform
}
