function is-released-version {
  [[ ${1} =~ ^([0-9]+\.){1,2}[0-9]+(-rc[0-9]+){0,1}$ ]] && return 0
}

function is-rc-version {
  [[ ${1} =~ .*-rc[0-9]+$ ]] && return 0
}

function get-docker-tag {
  pushd "${DEIS_ROOT}" &> /dev/null
  echo "git-$(git rev-parse --short HEAD)"
  popd &> /dev/null
}

function can-use-ci-artifacts {
  local docker_tag="$(get-docker-tag)"

  pushd "${DEIS_ROOT}" &> /dev/null
    if [ -z "$(git status --porcelain)" ] && \
       docker-hub-contains-image "store-monitor" "${docker_tag}"; then
      return 0
    else
      rerun_log error "Deis repo ($(pwd)) contains changes, can't use CI artifacts in Docker Hub."
      return 1
    fi
  popd &> /dev/null
}

function docker-hub-contains-image {
  image="${1}"
  docker_tag="${2}"
  repository="${3:-deisci}"

  curl -s "https://hub.docker.com/v2/repositories/${repository}/${image}/tags/" \
    | jq '.results[].name' \
    | grep -q "${docker_tag}"
}

function checkout-deis {
  local dir="${1}"
  local version="${2:-master}"
  local repo="${3:-${DEIS_GIT_REPO}}"

  if is-released-version "${version}" || \
     is-rc-version "${version}"; then
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
    rerun_log "Using released version ${version}."
  elif can-use-ci-artifacts; then
    rerun_log "No need to build, CI artifacts in Docker Hub exist for $(get-docker-tag)."
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

  rerun_log warn "deisctl config platform set domain=${DEIS_TEST_DOMAIN}"
  deisctl config platform set domain="${DEIS_TEST_DOMAIN}"

  rerun_log warn "deisctl config platform set sshPrivateKey=${DEIS_TEST_SSH_KEY}"
  deisctl config platform set sshPrivateKey="${DEIS_TEST_SSH_KEY}"

  if is-released-version "${version}"; then
    rerun_log warn "deisctl config platform set version=v${version}"
    deisctl config platform set version="v${version}"
  elif can-use-ci-artifacts; then
    (
      cd "${DEIS_ROOT}"
      IMAGE_PREFIX="deisci/" make set-image
    )
  else
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
