## Install CouchDB ##

## Install Kafka ##

1) mkdir /usr/local/kafka_install
2) Download latest binary at http://kafka.apache.org/downloads.html
3) Copy download tgz file to /usr/local/kafka_install
4) Extract: tar -xzf <kafka-binary-tgz>
5) Create symlink for convenience: ln -s <extracted-kafka-bin-dir> kafka
6) Add following to env variables (add to ~/.bashrc or ~/.profile..whatever you use):
   - export KAFKA_HOME=/usr/local/kafka_install/kafka
   - export KAFKA=$KAFKA_HOME/bin
   - export KAFKA_CONFIG=$KAFKA_HOME/config

### Run Zookeeper and Kafka ###

$KAFKA/zookeeper-server-start.sh $KAFKA_CONFIG/zookeeper.properties
$KAFKA/kafka-server-start.sh $KAFKA_CONFIG/server.properties

