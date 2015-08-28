function check-etcd-alive {
  rerun_log "Waiting for etcd/fleet at ${DEISCTL_TUNNEL}"

  # wait for etcd up to 5 minutes
  WAIT_TIME=1
  until deisctl --request-timeout=1 list >/dev/null 2>&1; do
     (( WAIT_TIME += 1 ))
     if [ ${WAIT_TIME} -gt 300 ]; then
      rerun_log error "Timeout waiting for etcd/fleet"
      # run deisctl one last time without eating the error, so we can see what's up
      deisctl --request-timeout=1 list
      exit 1;
    fi
  done

  rerun_log "etcd available after ${WAIT_TIME} seconds"
}

function healthcheck-app {
  local app_name="${1}"

  rerun_log "Running healthcheck of previously deployed app: ${app_name}.."

  if ! curl -s "http://${app_name}.${DEIS_TEST_DOMAIN}" | grep -q "Powered by Deis"; then
    rerun_log error "Failed to pass healthcheck."
    return 1
  else
    rerun_log info "Healthcheck succeeded."
    return 0
  fi
}
