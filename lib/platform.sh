function is-released-version {
  [[ ${1} =~ ^([0-9]+\.){0,2}[0-9]$ ]] && return 0
}

function checkout-deis {
  local dir="${1}"
  local version="${2:-master}"
  local repo="${3:-${DEIS_GIT_REPO}}"

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
    git clone --depth 1 -b "${version}" ${repo} "${dir}"
  fi
}

function build-deis {
  local version="${1}"

  if is-released-version "${version}"; then
    deisctl config platform set version="v${version}"
  else
    check-docker
    check-registry
    (
      setup-go-dependencies
      cd "${DEIS_ROOT}"
      make build
    )
  fi
}

function deploy-deis {
  local version="${1}"

  check-etcd-alive

  deisctl config platform set domain="${DEIS_TEST_DOMAIN}"
  deisctl config platform set sshPrivateKey="${DEIS_TEST_SSH_KEY}"

  if ! is-released-version "${version}"; then
    (
      cd "${DEIS_ROOT}"
      make dev-release
    )
  fi

  deisctl install platform
  deisctl start platform

  _check-cluster
}

function undeploy-deis {
  deisctl stop platform
  deisctl uninstall platform
}
