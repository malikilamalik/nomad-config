#!/bin/bash
set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

sudo cockroach init --certs-dir=$APPLICATION_DIR/certs --host=$NODE_IP

sudo cockroach sql --certs-dir=$APPLICATION_DIR/certs --host=$NODE_IP

CREATE USER $USER WITH CONTROLCHANGEFEED CANCELQUERY CREATEROLE CREATELOGIN VIEWACTIVITY CREATEDB CONTROLJOB LOGIN PASSWORD $PASSWORD;
CREATE ROLE developer WITH CREATEDB;
GRANT developer TO $USER WITH ADMIN OPTION;