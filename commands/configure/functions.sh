function choose-deis-type {
  local options=(
                  "Released version"
                  "Official GitHub Repository"
                )

  choice-prompt "What Deis would you like to use?" options[@] 1 answer

  case ${answer} in
    1)
      prompt "Enter Deis version:" 1.9.0 VERSION
      ;;
    2)
      prompt "Enter Deis branch/tag/sha1:" master VERSION
      ;;
  esac
}

function configure-go {
  if [ -z "${GOPATH:-}" ]; then
    prompt "What's your GOPATH?" "${HOME}/go" GOPATH
  fi

  export PATH="${GOPATH}/bin:${PATH}"
  export ORIGINAL_PATH="${PATH}"
  echo-export GOPATH
  echo-export PATH
  echo-export ORIGINAL_PATH

}

function guess-ipaddr {
  /sbin/ifconfig vboxnet2 | grep 'inet ' | awk '{print $2}'
}

function configure-ipaddr {
  if [ -z "${HOST_IPADDR:-}" ]; then
    prompt "What's the ip address of your Docker environment?" "$(guess-ipaddr)" HOST_IPADDR
  fi
  echo-export HOST_IPADDR
}

function configure-registry {
  if [ -z "${DEV_REGISTRY:-}" ]; then
    prompt "Where can I find your Docker registry?" "192.168.59.103:5000" DEV_REGISTRY
  fi
  echo-export DEV_REGISTRY
}