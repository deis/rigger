function ssh-fingerprint {
  local private_key_file="${1}"

  local fingerprint="$(ssh-keygen -lf "${private_key_file}" 2>/dev/null | awk '{ print $2 }')"

  if [ $? -ne 0 ]; then
    return 1
  else
    echo "${fingerprint}"
  fi
}
