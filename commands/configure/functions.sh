function choose-build-type {
  export BUILD_TYPE
  local options=(
                  "full platform"
                  "clients only"
                )

  choice-prompt "What would you like me to build out of that repository?" options[@] 1 BUILD_TYPE

  case ${BUILD_TYPE} in
    2) # clients only
      configure-deis-version
      ;;
  esac

  save-vars BUILD_TYPE
}

function configure-user-type {
  local answer
  local options=(
                  "Release"
                  "Path (I'll just build whatever you have here)"
                  "Git (I'll manage the Git repo in a path of your choosing)"
                )

  choice-prompt "Where can I find the version of Deis you want?" options[@] 1 DEIS_SOURCE

  case ${DEIS_SOURCE} in
    1) # released version
      configure-deis-version
      export GOPATH="${DEIS_ID_DIR}/go"
      export DEIS_ROOT="${GOPATH}/src/github.com/deis/deis"
      save-vars GOPATH DEIS_ROOT
      ;;
    2) # path based version
      choose-build-type
      ;;
    3) # Git based version
      prompt "Enter Deis git repo url:" DEIS_GIT_REPO "https://github.com/deis/deis.git"
      prompt "Enter Deis git branch/tag/sha1:" DEIS_GIT_VERSION "master"
      choose-build-type
      export GOPATH="${DEIS_ID_DIR}/go"
      save-vars DEIS_GIT_REPO GOPATH
      ;;
  esac
  
  export DEIS_SOURCE
  save-vars DEIS_SOURCE
}

function configure-deisctl-tunnel {
  prompt "Enter Deisctl tunnel IP address:" DEISCTL_TUNNEL 127.0.0.1:2222
}

function configure-deis-version {
  prompt "Enter Deis version:" VERSION 1.10.0
  export VERSION
  save-vars VERSION
}

function configure-deis-repo-sha {
  prompt "Enter Deis repo sha:" DEIS_GIT_VERSION master

  export VERSION="${DEIS_GIT_VERSION}"
  save-vars DEIS_GIT_VERSION VERSION
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

function configure-ipaddr {
  prompt "What's the ip address of your Docker environment?" HOST_IPADDR "$(guess-ipaddr)"
}

function configure-registry {
  case ${PROVIDER:-} in
    vagrant)
      prompt "Where can I find your Docker registry?" DEV_REGISTRY "$(guess-registry)"
      ;;
    *)
      prompt "What's a publicly available Docker registry I can use?" DEV_REGISTRY "${SUGGEST_DEV_REGISTRY:-}"
      prompt "And an organization/user I can push to (include trailing /)?" IMAGE_PREFIX "${SUGGEST_IMAGE_PREFIX:-}"
      ;;
  esac

  save-vars DEV_REGISTRY IMAGE_PREFIX
}

function configure-app-deployment {
  prompt "What ssh key should I use for application deployment?" DEIS_TEST_AUTH_KEY "${SUGGEST_DEIS_SSH_KEY:-}"
  save-vars DEIS_TEST_AUTH_KEY
}

function configure-ssh {
  prompt "What ssh key should I use (for deisctl/ssh)?" DEIS_TEST_SSH_KEY "${SUGGEST_DEIS_SSH_KEY:-}"
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
