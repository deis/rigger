#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p save-vars [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "save-vars"

trap "rm -rf /tmp/riggervars" EXIT

function setup-vars-file {
  mkdir -p /tmp/riggervars
  mktemp /tmp/riggervars/vars.XXXXXX
}

source-defaults

it_passes_if_no_vars() {
  rigger-save-vars -f $(setup-vars-file)
}

it_fails_if_no_rigger_vars_file() {
  unset RIGGER_VARS_FILE
  ! rigger-save-vars -f
  source-defaults
}

it_checks_correct_parameters() {
  export RIGGER_VARS_FILE="$(setup-vars-file)"

  export R_TEST="something"

  rigger-save-vars R_TEST

  grep 'R_TEST="something"' "${RIGGER_VARS_FILE}"
}

it_writes_multiple_vars() {
  export RIGGER_VARS_FILE="$(setup-vars-file)"

  export R_TEST1="test_me!"
  export R_TEST2="test me too!"

  rigger-save-vars R_TEST1 R_TEST2

  grep 'R_TEST1="test_me!"' "${RIGGER_VARS_FILE}"
  grep 'R_TEST2="test me too!"' "${RIGGER_VARS_FILE}"
}

it_can_take_a_file_option() {

  local file="$(setup-vars-file)"

  export R_TEST4="some data"

  rigger-save-vars -f "${file}" R_TEST4

}
