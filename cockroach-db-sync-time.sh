set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# Sync Time
sudo timedatectl set-ntp no
sudo apt-get install -qq ntp
sudo service ntp stop
sudo ntpd -b time.google.com
sudo service ntp start
sudo ntpq -p