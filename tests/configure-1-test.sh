#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p configure [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "configure"

TMP=$(mktemp -d "/tmp/rigger_test_root.XXX")
export RIGGER_HOME="${TMP}"

trap "rm -rf ${TMP}" EXIT

source-defaults

it_fails_to_load_existing_config() {
  # needs file to exist
  ! rigger configure --file /tmp/deis/nothing-to-see-here
}

it_loads_existing_config() {
  local temp_vars_file="$(mktemp ${TMP}/rigger_existing_config.XXX)"

  cat <<EOF > "${temp_vars_file}"
GOPATH="${HOME}"
PATH="${GOPATH}/bin:${PATH}"
ORIGINAL_PATH="${PATH}"
DEIS_VARS_FILE="${temp_vars_file}"
EOF

  rigger configure --file "${temp_vars_file}"
}

function check-file-for-extras {
  local temp_vars_file="$(mktemp /${TMP}/file_extras_test.XXX)"

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
