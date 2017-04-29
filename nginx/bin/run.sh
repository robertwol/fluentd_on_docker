#!/bin/sh
FLUENTD_OPT=""
FLUENTD_CONF="fluent.conf"

# Start the first process
nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi

# Start the second process
fluentd -c /etc/fluentd/$FLUENTD_CONF -p /etc/fluentd/plugins $FLUENTD_OPT
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Fluentd: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
while /bin/true; do
  PROCESS_1_STATUS=$(ps aux |grep -q nginx)
  PROCESS_2_STATUS=$(ps aux |grep -q fluentd)
  if [ $PROCESS_!_STATUS || $PROCESS_2_STATUS ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  sleep 60
done
