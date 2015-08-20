#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m deis -p configure [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "configure"

it_fails_to_load_existing_config() {
  # needs file to exist
  ! ../rerun deis:configure --type existing --file /tmp/deis/nothing-here-to-see
}

it_can_configure_against_existing_cluster() {
  VERSION="1.9.0" DEISCTL_TUNNEL="127.0.0.1" ../rerun deis:configure --type existing
}

it_loads_existing_config() {
  local temp_vars_file="$(mktemp /tmp/deis-test-vars.XXX)"

  cat <<EOF > "${temp_vars_file}"
GOPATH="${HOME}"
PATH="${GOPATH}/bin:${PATH}"
ORIGINAL_PATH="${PATH}"
DEIS_VARS_FILE="${temp_vars_file}"
EOF

  ../rerun deis:configure --type existing --file "${temp_vars_file}"
}

it_creates_absolute_minimum_config() {
  local temp_vars_file="$(mktemp /tmp/deis-test-vars.XXX)"

  ../rerun deis:configure <<EOF
EOF

  ../rerun deis:shellinit > "${temp_vars_file}"

  vars_list="DEIS_ROOT
             DEIS_TEST_ID
             DEIS_TEST_ROOT
             DEIS_VARS_FILE
             GOPATH
             ORIGINAL_PATH
             PATH"

  for var in ${vars_list}; do
    sed -i .bak -e "/^export ${var}=.*$/d" "${temp_vars_file}"
  done

  if [ $(wc -l < "${temp_vars_file}") -gt 0 ]; then
    cat ${temp_vars_file}
    exit 1
  fi
}

