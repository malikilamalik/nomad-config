#!/bin/bash

mkdir -p $APPLICATION_DIR
cd $APPLICATION_DIR || exit 1

# Synchronize clocks
sudo timedatectl set-ntp no
timedatectl
sudo apt-get install -qq ntp
sudo service ntp stop
sudo ntpd -b time.google.com
sudo service ntp start

# Intalling CockroachDB
curl -O https://binaries.cockroachdb.com/cockroach-v21.2.7.linux-amd64.tgz
tar -xzvf cockroach-v21.2.7.linux-amd64.tgz
sudo cp -i cockroach-v21.2.7.linux-amd64/cockroach /usr/local/bin/
sudo mkdir -p /usr/local/lib/cockroach
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/

# Make Cert Directory
mkdir certs
mkdir my-safe-directory
cockroach cert create-ca \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key

# Generate Certificates
IFS=',' read -ra ADDR <<< "$JOIN"
for i in "${ADDR[@]}"; do
    IFS=';' read -ra NAME <<< "$i"
    curl -O https://raw.githubusercontent.com/malikilamalik/nomad-config/main/cockroach-create-cert.sh
    # process "$i"
    sed -i "s!||EXTERNAL_IP||!${NAME[0]}!g" cockroach-create-cert.sh
    sed -i "s!||NAME||!${NAME[1]}!g" cockroach-create-cert.sh
    source cockroach-create-cert.sh
    mkdir -p $APPLICATION_DIR/${NAME[1]}/certs
    mv certs/node.crt $APPLICATION_DIR/${NAME[1]}/certs
    mv certs/node.key $APPLICATION_DIR/${NAME[1]}/certs
    cp certs/ca.crt $APPLICATION_DIR/${NAME[1]}/certs
    rm cockroach-create-cert.sh
done

cockroach cert create-node \
root \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key