#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p os [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

source ../lib/os.sh

describe "os"

it_identifies_os() {
  function uname {
    echo "Darwin my-mac 14.5.0 Darwin Kernel Version 14.5.0: Wed Jul 29 02:26:53 PDT 2015; root:xnu-2782.40.9~1/RELEASE_X86_64 x86_64'"
  }

  [ $(which-os) == "darwin" ]

  function uname {
    echo "Linux"
  }

  [ $(which-os) == "linux" ]
}

it_identifies_machines_ip() {
  local ip=$(get-machine-ip)

  # 127 would imply localhost
  # 172 would imply default docker bridge
  ! [[ ${ip} =~ (127)|(172).* ]]
}
