#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rigger -p platform [--answers <>]
#

[[ -f ./functions.sh ]] && . ./functions.sh

describe "platform"

source ../lib/platform.sh

TEST_ROOT="$(mktemp -d /tmp/platform-test.XXX)"

trap "rm -rf ${TEST_ROOT}" EXIT

it_verifies_valid_release_versions() {
  is-released-version "1.11.0"
  is-released-version "1.11.0-rc1"
  is-released-version "0.1.4"
  ! is-released-version "master"
}

it_deploys_deis_platform() {

  local etcd_checked=1
  local deis_built=1
  local cluster_checked=1

  function check-etcd-alive {
    etcd_checked=0
  }

  function deisctl {
    [ ${1} == "config" ] &&
    [ ${2} == "platform" ] && return 0

    [ ${1} == "install" ] && return 0

    [ ${1} == "start" ] && return 0

    return 1
  }

  function is-released-version {
    return 1
  }

  function build-deis {
    deis_built=0
  }

  function _check-cluster {
    cluster_checked=0
  }

  function make {
    [ ${1} == "dev-release" ] && return 0
  }

  deploy-deis
  
  [ ${etcd_checked} ]
  [ ${deis_built} ]
  [ ${cluster_checked} ]
}

it_fails_when_arg_mismatch() {
  ! deploy-deis # requires arguments
}

it_undeploys_deis() {

  function deisctl {
    [[ ${@} == "stop platform" ]] ||
    [[ ${@} == "uninstall platform" ]]
  }

  undeploy-deis

}
