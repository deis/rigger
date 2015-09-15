#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p configure [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "configure"

it_fails_to_load_existing_config() {
  # needs file to exist
  ! rigger configure --type existing --file /tmp/deis/nothing-here-to-see
}

xit_can_configure_against_existing_cluster() {
  DEIS_VERSION="1.9.0" DEISCTL_TUNNEL="127.0.0.1" ../rerun deis:configure --type existing
}

it_loads_existing_config() {
  local temp_vars_file="$(mktemp /tmp/deis-test-vars.XXX)"

  cat <<EOF > "${temp_vars_file}"
GOPATH="${HOME}"
PATH="${GOPATH}/bin:${PATH}"
ORIGINAL_PATH="${PATH}"
DEIS_VARS_FILE="${temp_vars_file}"
EOF

  rigger configure --file "${temp_vars_file}"
}

function check-file-for-extras {
  local temp_vars_file="$(mktemp /tmp/deis-test-vars.XXX)"

  rigger shellinit > "${temp_vars_file}"

  local required_vars="DEIS_ROOT
                       DEIS_ID
                       DEIS_ID_DIR
                       DEIS_VARS_FILE
                       DEISCTL_UNITS
                       DEIS_TEST_AUTH_KEY
                       DEIS_TEST_SSH_KEY
                       DEIS_TEST_DOMAIN
                       GOPATH
                       ORIGINAL_PATH
                       PROVIDERs
                       PATH
                       VERSION"

  vars_list="${required_vars} ${1}"

  for var in ${vars_list}; do
    grep -q "${var}" "${temp_vars_file}"
    sed -i -e "/^export ${var}=.*$/d" "${temp_vars_file}"
  done

  if [ $(wc -l < "${temp_vars_file}") -gt 0 ]; then
    cat ${temp_vars_file}
    exit 1
  fi
}