function choose-deis-type {
  local options=(
                  "Released version"
                  "Official GitHub Repository"
                )

  choice-prompt "What Deis would you like to use?" options[@] 1 answer

  case ${answer} in
    1)
      prompt "Enter Deis version:" 1.9.0 VERSION
      ;;
    2)
      prompt "Enter Deis branch/tag/sha1:" master VERSION
      ;;
  esac
}