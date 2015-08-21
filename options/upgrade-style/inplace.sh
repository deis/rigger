function upgrade-deis {
  local from="${1}"
  local to="${2}"

  setup-clients "${from}"

  undeploy-deis

  setup-clients "${to}"

  deploy-deis "${to}"
}
