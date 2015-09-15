#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p setup-clients [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "setup-clients"

source ../lib/clients.sh

function save-vars {
  :
}

it_can_download_correct_deis() {
  local client_test
  local version_test

  function link-client {
    :
  }

  function download-client {
    client_test="${1}"
    version_test="${2}"
  }

  setup-deis-client "1.9.1"

  [ "${client_test}" == "deis-cli" ]
  [ "${version_test}" == "1.9.1" ]
}

it_can_download_correct_deisctl() {
  local client_test2
  local version_test2

  function move-units {
    :
  }

  function link-units {
    :
  }

  function link-client {
    :
  }

  function download-client {
    client_test2="${1}"
    version_test2="${2}"
  }

  setup-deisctl-client "1.9.1"


  [ "${client_test2}" == "deisctl" ]
  [ "${version_test2}" == "1.9.1" ]
}
