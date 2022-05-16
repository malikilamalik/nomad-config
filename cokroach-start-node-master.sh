#!/bin/bash

sudo ufw allow 26257/tcp
sudo ufw allow 8080/tcp

sudo cockroach start \
--certs-dir=$APPLICATION_DIR/$NODE_NAME/certs \
--listen-addr=$EXTERNAL_IP \
--join=$NODE_JOIN \
--cache=.25 \
--max-sql-memory=.25