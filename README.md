# Dataiku DSS Docker image

## Building Docker image

If you want to build this image locally, just clone this Git repository and run:
```
docker build -t saagie/dataiku-dss .
```

## HDFS Prerequisites

If you plan to run **Dataiku Enterprise Edition** and access your HDFS Data lake,
you'll need to create a `/user/dataiku` directory on your HDFS and give it write permissions for your Docker dataiku user (who may not match a HDFS dataiku user you may have created. For test purpose, you can try 777 permissions on that directory).

## Running Docker container

Running **Dataiku Free Edition**:
*(You may want to backup your projects on your host machine, then mount a volume on /home/dataiku/dss)*
```
docker run -it --rm -p 10000:10000 -v /host_path_to_dss_data/:/home/dataiku/dss --name dataiku saagie/dataiku-dss:latest
```

Running **Dataiku Enterprise Edition**:
*If you want to connect to your HDFS, you'll need to provide this container a set of Hadoop conf files (such as core-site.xml, hdfs-site.xml, hive-site.xml, etc.) by mounting a volume as done below (you can also mount a volume to store your DSS projects)*
*You may also need to use your host network (instead of Bridge mode) to avoid connectivity problems with your HDFS*
```
docker run -it --rm -p 10000:10000 -v /path_to_hadoop_conf_dir/:/etc/hadoop/conf -v /host_path_to_dss_data/:/home/dataiku/dss --net=host --name dataiku saagie/dataiku-dss:latest
```

# Hive connection setup

First, be sure that `hive-site.xml` is mounted as a volume in `/etc/hive/conf`.

Go to DSS Admin / Settings / Hadoop

Enable: Use advanced URL syntax
Driver class: org.apache.hive.jdbc.HiveDriver
Connection URL: jdbc:hive2://NAMENODE_IP:10000/default;user=dataiku;password=xxx;auth=plain
Default execution engine: HiveServer2

# Config with Sentry

- Disable impersonnation for Hive
- create a dssuser Role
- Grant:
```
GRANT ALL ON DATABASE xxx TO ROLE dssuser
GRANT ALL ON URI 'hdfs://ROOT_PATH_OF_THE_CONNECTION' TO ROLE dssuser
```

# Spark configuration

If mounting a volume to your container in order to share your Spark configuration, mount your `spark-env.sh` to `/usr/local/spark/conf/spark-env.sh` or `/opt/spark/conf/spark-env.sh`.
If you're also mounting `/tmp/spark` to keep track of your Spark executions, make sure this directory has the appropriate permissions on your host machine, so that user `dataiku` will be able to write in it from the container.

**Note that you must start Dataiku in `host` mode if you want it to be able to communicate with your Spark cluster.**

# Changing Dataiku base port

If you want to customize Dataiku base port (default is 10000), for example when running in host mode (to avoid: `port already in use` error), you can provide a `PORT0` environment variable at runtime.

For example:
```
docker run -it --rm --net=host --env PORT0=31000 -v /path_to_hadoop_conf_dir/:/etc/hadoop/conf -v /host_path_to_dss_data/:/home/dataiku/dss --net=host --name dataiku saagie/dataiku-dss:latest
```
