# wipe out all vagrants & deis virtualboxen
function cleanup {
    if [ "$SKIP_CLEANUP" != true ]; then
        log_phase "Cleaning up"
        set +e
        ${GOPATH}/src/github.com/deis/deis/tests/bin/destroy-all-vagrants.sh
        VBoxManage list vms | grep deis | sed -n -e 's/^.* {\(.*\)}/\1/p' | xargs -L1 -I {} VBoxManage unregistervm {} --delete
        vagrant global-status --prune
        docker rm -f -v `docker ps | grep deis- | awk '{print $1}'` 2>/dev/null
        log_phase "Test run complete"
    fi
}

function dump_logs {
  log_phase "Error detected, dumping logs"
  TIMESTAMP=`date +%Y-%m-%d-%H%M%S`
  FAILED_LOGS_DIR=$HOME/deis-test-failure-$TIMESTAMP
  mkdir -p $FAILED_LOGS_DIR
  set +e
  export FLEETCTL_TUNNEL=$DEISCTL_TUNNEL
  fleetctl -strict-host-key-checking=false list-units
  # application unit logs
  for APP in `fleetctl -strict-host-key-checking=false list-units --no-legend --fields=unit | grep -v "deis-"`;do
    CURRENT_APP=$(echo $APP | sed "s/\.service//")
    #echo "$CURRENT_APP"
    get_journal_logs $CURRENT_APP
  done
  # component logs
  get_logs deis-builder
  get_logs deis-controller
  get_logs deis-database
  get_logs deis-logger
  get_logs deis-registry@1 deis-registry deis-registry-1
  get_logs deis-router@1 deis-router deis-router-1
  get_logs deis-router@2 deis-router deis-router-2
  get_logs deis-router@3 deis-router deis-router-3
  # deis-store logs
  get_logs deis-router@1 deis-store-monitor deis-store-monitor-1
  get_logs deis-router@1 deis-store-daemon deis-store-daemon-1
  get_logs deis-router@1 deis-store-metadata deis-store-metadata-1
  get_logs deis-router@1 deis-store-volume deis-store-volume-1
  get_logs deis-router@2 deis-store-monitor deis-store-monitor-2
  get_logs deis-router@2 deis-store-daemon deis-store-daemon-2
  get_logs deis-router@2 deis-store-metadata deis-store-metadata-2
  get_logs deis-router@2 deis-store-volume deis-store-volume-2
  get_logs deis-router@3 deis-store-monitor deis-store-monitor-3
  get_logs deis-router@3 deis-store-daemon deis-store-daemon-3
  get_logs deis-router@3 deis-store-metadata deis-store-metadata-3
  get_logs deis-router@3 deis-store-volume deis-store-volume-3
  get_logs deis-store-gateway

  # docker logs
  fleetctl -strict-host-key-checking=false ssh deis-router@1 journalctl --no-pager -u docker \
    > $FAILED_LOGS_DIR/docker-1.log
  fleetctl -strict-host-key-checking=false ssh deis-router@2 journalctl --no-pager -u docker \
    > $FAILED_LOGS_DIR/docker-2.log
  fleetctl -strict-host-key-checking=false ssh deis-router@3 journalctl --no-pager -u docker \
    > $FAILED_LOGS_DIR/docker-3.log

  # etcd logs
  fleetctl -strict-host-key-checking=false ssh deis-router@1 journalctl --no-pager -u etcd \
    > $FAILED_LOGS_DIR/debug-etcd-1.log
  fleetctl -strict-host-key-checking=false ssh deis-router@2 journalctl --no-pager -u etcd \
    > $FAILED_LOGS_DIR/debug-etcd-2.log
  fleetctl -strict-host-key-checking=false ssh deis-router@3 journalctl --no-pager -u etcd \
    > $FAILED_LOGS_DIR/debug-etcd-3.log

  # etcdctl dump
  fleetctl -strict-host-key-checking=false ssh deis-router@1 etcdctl ls / --recursive \
    > $FAILED_LOGS_DIR/etcdctl-dump.log

  # tarball logs
  BUCKET=jenkins-failure-logs
  FILENAME=deis-test-failure-$TIMESTAMP.tar.gz
  cd $FAILED_LOGS_DIR && tar -czf $FILENAME *.log && mv $FILENAME .. && cd ..
  rm -rf $FAILED_LOGS_DIR
  if [ `which s3cmd` ] && [ -f $HOME/.s3cfg ]; then
    echo "configured s3cmd found in path. Attempting to upload logs to S3"
    s3cmd put $HOME/$FILENAME s3://$BUCKET
    rm $HOME/$FILENAME
    echo "Logs are accessible at https://s3.amazonaws.com/$BUCKET/$FILENAME"
  else
    echo "Logs are accessible at $HOME/$FILENAME"
  fi
  exit 1
}

function get_logs {
  TARGET="$1"
  CONTAINER="$2"
  FILENAME="$3"
  if [ -z "$CONTAINER" ]; then
    CONTAINER=$TARGET
  fi
  if [ -z "$FILENAME" ]; then
    FILENAME=$TARGET
  fi
  fleetctl -strict-host-key-checking=false ssh "$TARGET" docker logs "$CONTAINER" > $FAILED_LOGS_DIR/$FILENAME.log
}

function get_journal_logs {
  TARGET="$1"
  fleetctl -strict-host-key-checking=false journal --lines=1000 "$TARGET" > $FAILED_LOGS_DIR/$TARGET.log
}
