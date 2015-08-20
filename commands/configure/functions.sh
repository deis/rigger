function choose-deis-version {

  :

  # local options=(
  #                 "Released version"
  #                 "Official GitHub Repository"
  #               )

  # choice-prompt "What Deis would you like to use?" options[@] 1 answer

  # case ${answer} in
  #   1)
  #     prompt "Enter Deis version:" 1.9.0 VERSION
  #     ;;
  #   2)
  #     prompt "Enter Deis branch/tag/sha1:" master VERSION
  #     ;;
  # esac
}

function need-deis-repo {
  ! is-released-version "${VERSION}"
}

function configure-deisctl-tunnel {
  prompt "Enter Deisctl tunnel IP address:" 127.0.0.1:2222 DEISCTL_TUNNEL
}

function configure-deis-version {
  prompt "Enter Deis version:" master VERSION
}

function configure-go {
  ORIGINAL_PATH="${PATH}"
  export ORIGINAL_PATH

  prompt "What's your GOPATH?" "${HOME}/go" GOPATH

  export PATH="${GOPATH}/bin:${PATH}"
}

function configure-deis-root {
  # Needed to run provisioning (provisioning scripts located in repo)
  prompt "Where is the Deis repository located?" "${GOPATH:-${HOME}}/src/github.com/deis/deis" DEIS_ROOT
}

function configure-ipaddr {
  prompt "What's the ip address of your Docker environment?" "$(guess-ipaddr)" HOST_IPADDR
}

function configure-registry {
  if need-deis-repo; then
    prompt "Where can I find your Docker registry?" "$(guess-registry)" DEV_REGISTRY
  fi
}