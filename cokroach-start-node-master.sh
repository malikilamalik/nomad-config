#!/bin/bash

cockroach start \
--certs-dir=$APPLICATION_DIR/$NAME/certs \
--advertise-addr=$NODE_IP \
--join=$NODE_JOIN \
--cache=.25 \
--max-sql-memory=.25 \
--background