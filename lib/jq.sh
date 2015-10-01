function install-jq {
  local os="$(uname | tr '[:upper:]' '[:lower:]')"
  local arch="$(uname -m)"
  local version="1.5"
  local jq_base_url="https://github.com/stedolan/jq/releases/download/jq-${version}"

  if [ -f "${EXTERNAL_BIN_DIR}/jq" ]; then
    return 0
  fi

  case ${arch} in
    x86_64)
      if [ ${os} == darwin ]; then
        arch=amd64
      elif [ ${os} == linux ]; then
        arch=64
      fi
      ;;
    *)
      rerun_die "${arch} is not a currently supported combination between rigger/jq"
      ;;
  esac

  case ${os} in
    darwin)
      jq_bin_name="jq-osx-${arch}"
      ;;
    linux)
      jq_bin_name="jq-linux${arch}"
      ;;
    *)
      rerun_die "${os} is not a currently supported combination between rigger/jq"
      ;;
  esac

  mkdir -p "${EXTERNAL_BIN_DIR}"
  curl -L "${jq_base_url}/${jq_bin_name}" -o "${EXTERNAL_BIN_DIR}/jq"
  chmod +x "${EXTERNAL_BIN_DIR}/jq"
}
