#!/bin/bash

DSS_INSTALLDIR="/home/dataiku/dataiku-dss-$DSS_VERSION"

# Run dataiku so that it creates /home/dataiku/dss folder and setup everything
echo "Running DSS"
/home/dataiku/run.sh &

# Wait a few sec to be sure everything runs fine
sleep 30

# Copy JDBC jars and dependencies
mkdir -p /home/dataiku/dss/lib/jdbc
cp /home/dataiku/lib/* /home/dataiku/dss/lib/jdbc

# Stop DSS
"$DSS_DATADIR"/bin/dss stop

# If Dataiku is running in Host mode, change its base port
if [ -z $PORT0 ]
then
  export PORT0=$(( $PORT+1 ))
  echo "No PORT0 variable provided, running Dataiku on default port."
else
  echo "Changing Dataiku base port to $PORT0"
  mv "$DSS_DATADIR"/install.ini "$DSS_DATADIR"/install.ini.bak
  sed "s/port = .*$/port = $PORT0/g" "$DSS_DATADIR"/install.ini.bak > "$DSS_DATADIR"/install.ini
  "$DSS_DATADIR"/bin/dssadmin regenerate-config
fi

# setting up DSS Hadoop integration
"$DSS_DATADIR"/bin/dssadmin install-hadoop-integration

# Setting up spark
# As volumes are mounted at container startup,
# we need to grab mounted Spark conf and overwrite the default one before
# before running Zepplin
if [ -f "/usr/local/spark/conf/spark-env.sh" ]
then
  # overwrite Spark 2.1.0 config
  echo "INFO: ovewriting default spark-env.sh"
  cp /usr/local/spark/conf/spark-env.sh /opt/spark/conf
else
  # use default config
  echo "WARNING: NO CUSTOM spark-env.sh PROVIDED. USING DEFAULT TEMPLATE."
  cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
fi
chmod 755 /opt/spark/conf/spark-env.sh

"$DSS_DATADIR"/bin/dssadmin install-spark-integration -sparkHome /opt/spark

# wait a few sec
sleep 15

# start DSS
# /home/dataiku/run.sh
"$DSS_DATADIR"/bin/dss start

# keep the container running with this hack...
tail -f /dev/null
