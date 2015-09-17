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
