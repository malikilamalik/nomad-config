#!/bin/bash

cockroach cert create-node \
||EXTERNAL_IP|| \
||INTERNAL_IP|| \
||NAME||  \
localhost \
127.0.0.1 \
--certs-dir=certs \
--ca-key=my-safe-directory/ca.key