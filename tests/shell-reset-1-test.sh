#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p shell-reset [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "shell-reset"

it_would_unset_all_vars_but_path() {
  local varsfile="$(mktemp -t tempvars)"
  cat <<EOF > "${varsfile}"
export PATH="mypath!:saveit!"
export DEIS_ROOT="some_path_here"
export RIGGER_HOME="my home sweet home"
EOF

  local returned="$(rigger shell-reset --file "${varsfile}")"
  echo "${returned}" | grep DEIS_ROOT
  echo "${returned}" | grep RIGGER_HOME
  ! echo "${returned}" | grep PATH
}

