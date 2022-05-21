#!/bin/bash
set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

sudo ufw allow 26257/tcp
sudo ufw allow 8080/tcp

# Intalling CockroachDB
curl -O https://binaries.cockroachdb.com/cockroach-v21.2.7.linux-amd64.tgz
tar -xzvf cockroach-v21.2.7.linux-amd64.tgz
sudo rm -f /usr/local/bin/cockroach
sudo cp -i cockroach-v21.2.7.linux-amd64/cockroach /usr/local/bin/
sudo mkdir -p /usr/local/lib/cockroach
sudo rm -f /usr/local/lib/cockroach/libgeos.so
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo rm -f /usr/local/lib/cockroach/libgeos_c.so
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/


sudo cockroach start \
--certs-dir=$APPLICATION_DIR/$NODE_NAME/slave-certs/certs \
--advertise-addr=$EXTERNAL_IP \
--join=$NODE_JOIN \
--cache=.25 \
--max-sql-memory=.25