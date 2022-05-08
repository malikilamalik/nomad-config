#!/bin/bash

trap 'kill $!' INT
(
i=1
sp='/-\|'
no_config=true
echo "type Ctrl+C to exit this while loop"
echo "if you feel the conditions for continuing successfully have been met... ";
while $no_config; do
    printf "\b${sp:i++%${#sp}:1}"
    [[ ! $(pidof SupremeCommande) && -f ~/My\ Documents/newfile ]] && no_config=false
    sleep 1
done
) &
wait
trap 'trap - INT; kill -INT $$' INT
echo "do more stuff"