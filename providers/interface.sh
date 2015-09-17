function run-provider-step {
  local filename="${1}"

  local file="${PROVIDER_DIR}/${PROVIDER:-}/${filename}"
  rerun_log debug "running ${file}"

  if [ -f "${file}" ]; then
    pushd ${PROVIDER_DIR}/${PROVIDER} &> /dev/null
    rerun_log debug "Running script ${file}"
    
    # run it! are your fingers crossed?
    ${file}

    popd &> /dev/null
  elif [ -f "${file}.sh" ]; then
    rerun_log debug "Sourcing ${file}.sh"
    source "${file}.sh"
  else
    not-implemented ${file}
  fi
}

function not-implemented {
  local file="${1}"

  rerun_log fatal "No implementation for ${FUNCNAME[2]} found at ${file}"
  exit 1
}

function _setup-provider-dependencies {
  rerun_log warn "Installing dependencies for ${PROVIDER}..."
  run-provider-step install
}

function _create {
  rerun_log warn "Provisioning infrastructure on ${PROVIDER}..."
  run-provider-step create
}

function _destroy {
  rerun_log warn "Destroying infrastructure on ${PROVIDER}..."
  run-provider-step destroy
}

function _check-cluster {
  rerun_log warn "Checking infrastructure on ${PROVIDER}..."
  run-provider-step check
}

function _configure {
  rerun_log warn "Configuring ${PROVIDER} provider..."
  run-provider-step config
}
