function which-os {
  local uname_result="$(uname -a)"

  if [[ "${uname_result}" =~ "Darwin" ]]; then
    echo "darwin"
  elif [[ "${uname_result}" =~ "Linux" ]]; then
    echo "linux"
  else
    echo "windows"
  fi
}

function guess-ipaddr {
  if [ $(which-os) == "darwin" ]; then
    ifconfig vboxnet2 | grep 'inet ' | awk '{print $2}'
  else
    ifconfig en0 | grep 'inet ' | awk '{print $2}'
  fi
}

function guess-registry {
  local ip

  if [ $(which-os) == "darwin" ]; then
    if which boot2docker &> /dev/null; then
      # xargs trims leading/trailing whitespace
      ip="$(boot2docker config | grep "LowerIP" | cut -d = -f 2 | xargs)"
    fi
  else
    ip="$(guess-ipaddr)"
  fi

  echo "${ip}:5000"
}
