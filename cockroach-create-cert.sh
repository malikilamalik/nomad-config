#!/bin/bash

cockroach cert create-node \
10.127.212.137 \
103.183.75.7 \
cockroach-db-master  \
localhost \
127.0.0.1 \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key