# Intalling CockroachDB
curl -O https://binaries.cockroachdb.com/cockroach-v21.2.7.linux-amd64.tgz
tar -xzvf cockroach-v21.2.7.linux-amd64.tgz
sudo cp -i cockroach-v21.2.7.linux-amd64/cockroach /usr/local/bin/
sudo mkdir -p /usr/local/lib/cockroach
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos.so /usr/local/lib/cockroach/
sudo cp -i cockroach-v21.2.7.linux-amd64/lib/libgeos_c.so /usr/local/lib/cockroach/


cockroach start \
--certs-dir=drone-gitlab/certs \
--advertise-addr=103.181.143.219 \
--join=103.171.84.219,103.181.143.219 \
--cache=.25 \
--max-sql-memory=.25 \
--background