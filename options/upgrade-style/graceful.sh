function upgrade-deis {
  local from="${1}"
  local to="${2}"

  setup-clients "${from}"

  deisctl upgrade-prep

  healthcheck-app "testing"

  setup-clients "${to}"

  deploy-deis "${to}"

  deisctl upgrade-takeover
}
