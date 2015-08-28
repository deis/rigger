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

it_guesses_registry_on_boot2docker() {
  function which-os {
    echo "darwin"
  }

  function boot2docker {
    if [ ${1} == config ]; then
      echo "LowerIP = 192.168.59.103"
    fi
  }

  [ "$(guess-registry)" == "192.168.59.103:5000" ]
}

it_guesses_registry_on_host() {
  function which-os {
    echo "linux"
  }

  [ "$(guess-registry)" == "$(guess-ipaddr):5000" ]
}

it_guesses_hostipaddr_darwin() {
  function which-os {
    echo "darwin"
  }

  [ "$(guess-ipaddr)" == "192.168.59.3" ]
}

it_guesses_hostipaddr_linux() {
  function which-os {
    echo "linux"
  }

  function ifconfig {
    cat <<EOF
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
  ether a4:5e:60:f0:ec:89
  inet6 fe80::a65e:60ff:fef0:ec89%en0 prefixlen 64 scopeid 0x5
  inet 10.0.1.9 netmask 0xffffff00 broadcast 10.0.1.255
  nd6 options=1<PERFORMNUD>
  media: autoselect
  status: active
EOF
  }

  [ "$(guess-ipaddr)" == "10.0.1.9" ]
}
