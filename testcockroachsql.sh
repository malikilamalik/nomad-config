#!/bin/bash

sudo cockroach sql  --execute="CREATE USER $USER WITH CONTROLCHANGEFEED CANCELQUERY CREATEROLE CREATELOGIN VIEWACTIVITY CREATEDB CONTROLJOB LOGIN PASSWORD '$PASSWORD'" --certs-dir=$APPLICATION_DIR/certs --host=$NODE_IP
sudo cockroach sql  --execute="CREATE ROLE developer WITH CREATEDB" --certs-dir=$APPLICATION_DIR/certs --host=$NODE_IP
sudo cockroach sql  --execute="GRANT developer TO $USER WITH ADMIN OPTION;" --certs-dir=$APPLICATION_DIR/certs --host=$NODE_IP
