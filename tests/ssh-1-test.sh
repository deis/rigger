#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p ssh [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "ssh"

source ../lib/ssh.sh

it_parses_old_ssh_keygen() {
  function ssh-keygen {
    if [ "${1}" == "-" ]; then
      echo
    elif [ "${1}" == "-lf" ]; then
      echo "4096 e8:b6:fa:d3:6f:25:fe:b6:e3:b8:a5:31:ef:53:22:fb  test@example.com (RSA)"
    fi
  }

  [ "$(ssh-fingerprint "test")" == "e8:b6:fa:d3:6f:25:fe:b6:e3:b8:a5:31:ef:53:22:fb" ]
}

it_parses_new_ssh_keygen() {
  function ssh-keygen {
    if [ "${1}" == "-" ]; then
      echo " -E ... "
    elif [ "${1}" == "-E" ]; then
      echo "2048 MD5:c7:e8:c0:2f:37:8e:e2:87:d2:7a:0c:bc:aa:2d:27:85 test@example.com (RSA)"
    fi
  }

  [ "$(ssh-fingerprint "test")" == "c7:e8:c0:2f:37:8e:e2:87:d2:7a:0c:bc:aa:2d:27:85" ]
}
