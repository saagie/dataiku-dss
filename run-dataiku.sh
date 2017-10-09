#!/bin/bash

# Run dataiku so that it creates /home/dataiku/dss folder and setup everything
echo "Running DSS"
/home/dataiku/run.sh &

# wait a few sec to be sure everything runs fine
sleep 30

# Copy JDBC jars and dependencies
mkdir -p /home/dataiku/dss/lib/jdbc
cp /home/dataiku/lib/* /home/dataiku/dss/lib/jdbc

# stop DSS
/home/dataiku/dss/bin/dss stop

# wait a few sec
sleep 15

# start DSS
/home/dataiku/run.sh

# keep the container running with this hack...
tail -f /dev/null
