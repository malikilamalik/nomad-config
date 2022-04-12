#!/bin/bash

mkdir -p $APPLICATION_DIR
cd $APPLICATION_DIR || exit 1


# Install SSH pass
sudo apt-get install -qq sshpass

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

    sudo -u nomad mkdir -p /home/nomad/.ssh/
    sudo -u nomad ssh-keygen -t rsa -N "" -f /home/nomad/.ssh/id_rsa
    sudo -u nomad ssh-keyscan ${NAME[0]} | sudo -u nomad tee -a /home/nomad/.ssh/known_hosts
    sudo sshpass -p ${NAME[3]} ssh-copy-id -i /home/nomad/.ssh/id_rsa.pub -p 22 ${NAME[2]}@${NAME[0]}

    sudo ssh -i /home/nomad/.ssh/id_rsa ${NAME[2]}@${NAME[0]} "mkdir -p /home/${NAME[2]}/slave-certs/certs/"
    sudo scp -i /home/nomad/.ssh/id_rsa $APPLICATION_DIR/${NAME[1]}/certs/node.crt ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/node.crt
    sudo scp -i /home/nomad/.ssh/id_rsa $APPLICATION_DIR/${NAME[1]}/certs/node.key  ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/node.key
    sudo scp -i /home/nomad/.ssh/id_rsa $APPLICATION_DIR/${NAME[1]}/certs/ca.crt  ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/ca.crt
    sudo ssh -i /home/nomad/.ssh/id_rsa ${NAME[2]}@${NAME[0]} "sudo rm -drf $APPLICATION_DIR/${NAME[1]}/ && sudo mkdir -p $APPLICATION_DIR/${NAME[1]}/ && sudo mv /home/${NAME[2]}/slave-certs $APPLICATION_DIR/${NAME[1]}/ && sudo chown -R nomad:nomad $APPLICATION_DIR/"
    rm cockroach-create-cert.sh
done

cockroach cert create-node \
root \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key