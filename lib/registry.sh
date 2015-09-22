function activate-docker-machine-env {
  if [ $(which-os) == darwin ]; then
    eval "$(docker-machine env deis-registry)"
    save-vars DOCKER_TLS_VERIFY DOCKER_HOST DOCKER_CERT_PATH DOCKER_MACHINE_NAME
  fi
}

function create-dev-registry {
  (
    cd ${DEIS_ROOT}
    rerun_log warn "Creating local Docker registry..."
    make dev-registry > /dev/null
  )

  local host_ip="${HOST_IPADDR:-$(get-machine-ip)}"
  export DEV_REGISTRY="${host_ip}:5000"
  save-vars DEV_REGISTRY
}

function create-docker-env {
# we only need docker-machine for Mac (for now)

  case $(which-os) in
    darwin)
      rerun_log warn "Configuring local Docker environment..."
      if ! command -v docker-machine &> /dev/null; then
        brew install docker-machine
      fi

      if docker-machine ls | tail -n +2 | grep -qv deis-registry; then
        docker-machine create \
                       --driver virtualbox \
                       --virtualbox-disk-size=100000 \
                       --engine-insecure-registry=192.168.0.0/16 \
                       deis-registry
      fi

      activate-docker-machine-env
      ;;
  esac
}
