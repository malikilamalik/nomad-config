#!/bin/bash
set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

#One time
sudo -u nomad ssh-keygen -t rsa -N "" -f /etc/nomad.d/.ssh/id_rsa