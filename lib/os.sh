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

function get-machine-ip {
  ifconfig $({ route get 4.2.2.2 || route -n; } 2>/dev/null | \
    awk '/UG/ {print $8}; /interface:/ {print $2}' | head -n 1
  ) | awk '/inet / {print $2}' | sed -e 's/addr://'
}
