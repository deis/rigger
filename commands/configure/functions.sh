function configure-user-type {
  local answer
  local options=(
                  "Release"
                  "Path"
                  "Git"
                )

  choice-prompt "Where can I find the version of Deis you want?" options[@] 1 DEIS_SOURCE

  case ${DEIS_SOURCE} in
    1) # released version
      configure-deis-version
      export DEIS_GIT_REPO="${DEIS_GIT_REPO:-"${SUGGEST_DEIS_GIT_REPO}"}"
      export DEIS_GIT_VERSION="${VERSION}"
      configure-deis-repo
      export GOPATH="${DEIS_ID_DIR}/go"
      export DEIS_ROOT="${GOPATH}/src/github.com/deis/deis"
      save-vars GOPATH DEIS_ROOT
      ;;
    2) # path based version
      ;;
    3) # Git based version
      configure-deis-repo
      export GOPATH="${DEIS_ID_DIR}/go"
      export DEIS_ROOT="${GOPATH}/src/github.com/deis/deis"
      save-vars GOPATH DEIS_ROOT
      ;;
  esac
  
  export DEIS_SOURCE
  save-vars DEIS_SOURCE
}

function configure-deis-version {
  prompt "Enter Deis version:" VERSION "${SUGGEST_DEIS_VERSION}"
  export VERSION
  save-vars VERSION
}

function configure-deis-repo {
  prompt "Enter Deis git repo url:" DEIS_GIT_REPO "${SUGGEST_DEIS_GIT_REPO}"
  prompt "Enter Deis git branch/tag/sha1:" DEIS_GIT_VERSION "${SUGGEST_DEIS_GIT_VERSION}"

  export VERSION="${DEIS_GIT_VERSION}"
  save-vars DEIS_GIT_REPO DEIS_GIT_VERSION VERSION
}

function configure-go {
  ORIGINAL_PATH="${PATH}"
  export ORIGINAL_PATH
  save-vars ORIGINAL_PATH

  prompt "What's your GOPATH?" GOPATH "${SUGGEST_GOPATH}"

  export PATH="${GOPATH}/bin:${PATH}"
  save-vars PATH GOPATH
}

function configure-deis-root {
  # Needed to run provisioning (provisioning scripts located in repo)
  prompt "Where is the Deis repository located?" DEIS_ROOT "${GOPATH:-${HOME}}/src/github.com/deis/deis"

  save-vars DEIS_ROOT
}

function configure-registry {
  if [ ${DEIS_SOURCE} -eq 1 ]; then
    export DEV_REGISTRY="registry.hub.docker.com"
    export IMAGE_PREFIX="deis"
  fi

  case ${PROVIDER:-} in
    vagrant)
      create-dev-registry
      ;;
  esac

  prompt "What's a publicly available Docker registry I can use?" DEV_REGISTRY "${SUGGEST_DEV_REGISTRY:-}"
  prompt "And an organization/user I can push to (include trailing /)?" IMAGE_PREFIX "${SUGGEST_IMAGE_PREFIX:-}"
  save-vars DEV_REGISTRY IMAGE_PREFIX
}

function configure-app-deployment {
  if [ "${ADVANCED}" == "false" ]; then
    export DEIS_TEST_AUTH_KEY_FULL="${DEIS_TEST_SSH_KEY}"
  fi

  ssh-private-key-prompt "What private ssh key should I use for application deployment?" DEIS_TEST_AUTH_KEY_FULL "${DEIS_TEST_SSH_KEY:-}"
  export DEIS_TEST_AUTH_KEY="$(basename ${DEIS_TEST_AUTH_KEY_FULL})"
  save-vars DEIS_TEST_AUTH_KEY DEIS_TEST_AUTH_KEY_FULL
}

function configure-ssh {
  if [ "${ADVANCED}" == "false" ]; then
    export DEIS_TEST_SSH_KEY="${SSH_PRIVATE_KEY_FILE:-}"
  fi

  ssh-private-key-prompt "What private ssh key should I use (for deisctl/ssh)?" DEIS_TEST_SSH_KEY "${SSH_PRIVATE_KEY_FILE:-}"
  save-vars DEIS_TEST_SSH_KEY
}

function configure-dns {
  prompt "What wildcard domain name is available for me to use?" DEIS_TEST_DOMAIN "${SUGGEST_DEIS_TEST_DOMAIN:-}"
  save-vars DEIS_TEST_DOMAIN
}

function choose-provider {
  if [ -z "${PROVIDER:-}" ]; then

    declare -a options

    local search_return
    search_return="$(find ${PROVIDER_DIR} -name create -type f)"

    if [ -z "${search_return:-}" ]; then
      rerun_log fatal "No providers compatible with rigger found in ${PROVIDER_DIR}. :-("
      exit 1
    fi

    for provider in ${search_return}; do
      options+=("$(basename $(dirname ${provider}))")
    done

    local answer
    choice-prompt "What cloud provider would you like to use?" options[@] 1 answer

    export PROVIDER="${options[$(expr ${answer} - 1)]}"
  fi

  save-vars PROVIDER
}
