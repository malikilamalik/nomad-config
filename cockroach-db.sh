#!/bin/bash
set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR


mkdir -p $APPLICATION_DIR
cd $APPLICATION_DIR || exit 1


# Install SSH pass
sudo apt-get install -qq sshpass

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

# Make Cert Directory
rm -drf certs
mkdir -p certs
rm -drf my-safe-directory
mkdir -p my-safe-directory
cockroach cert create-ca \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key

n=1
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
    if [[ $n -gt 1 ]]
    then
        sudo -u nomad ssh-keyscan ${NAME[0]} | sudo -u nomad tee -a /etc/nomad.d/.ssh/known_hosts
        sudo -u nomad sshpass -p ${NAME[3]} ssh-copy-id -f -p 22 ${NAME[2]}@${NAME[0]}

        sudo -u nomad ssh ${NAME[2]}@${NAME[0]} "mkdir -p /home/${NAME[2]}/slave-certs/certs/"
        sudo -u nomad scp  $APPLICATION_DIR/${NAME[1]}/certs/node.crt ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/node.crt
        sudo -u nomad scp $APPLICATION_DIR/${NAME[1]}/certs/node.key  ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/node.key
        sudo -u nomad scp $APPLICATION_DIR/${NAME[1]}/certs/ca.crt  ${NAME[2]}@${NAME[0]}:/home/${NAME[2]}/slave-certs/certs/ca.crt
        sudo -u nomad ssh  ${NAME[2]}@${NAME[0]} "sudo rm -drf $APPLICATION_DIR/${NAME[1]}/ && sudo mkdir -p $APPLICATION_DIR/${NAME[1]}/ && sudo mv /home/${NAME[2]}/slave-certs $APPLICATION_DIR/${NAME[1]}/ && sudo chown -R nomad:nomad $APPLICATION_DIR/"
    fi
    n=$((n+1))
    rm cockroach-create-cert.sh
done

cockroach cert create-node \
root \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key