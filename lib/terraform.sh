function install-terraform {
  local os="$(uname | tr '[:upper:]' '[:lower:]')"
  local arch="$(uname -m)"
  local terraform_version="0.6.3"
  local terraform_base_url="https://dl.bintray.com/mitchellh/terraform"
  local terraform_filename

  case ${arch} in
    x86_64)
      arch=amd64
      ;;
    *)
      rerun_die "${arch} is not a currently supported combination between rigger/terraform"
      ;;
  esac

  terraform_filename="terraform_${terraform_version}_${os}_${arch}.zip"

  mkdir -p "${TERRAFORM_DIR}"
  (
    cd ${TERRAFORM_DIR}
    if [ ! -e terraform ]; then
      rerun_log "Downloading Terraform..."
      rerun_log debug "installing in ${TERRAFORM_DIR}"
      curl -L "${terraform_base_url}/${terraform_filename}" -o "${terraform_filename}"
      unzip "${terraform_filename}"
    fi
  )

  if ! command -v terraform &>/dev/null; then
    export PATH="${TERRAFORM_DIR}:${PATH}"
    save-vars PATH
  else
    rerun_log "Terraform already installed ($(command -v terraform))."
  fi
}
