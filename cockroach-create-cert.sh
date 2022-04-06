#!/bin/bash

cockroach cert create-node \
||EXTERNAL_IP|| \
||NAME||  \
||NAME|| \
localhost \
127.0.0.1 \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key