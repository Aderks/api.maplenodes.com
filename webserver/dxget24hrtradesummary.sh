#! /bin/bash

input=$1

if [ ${input} == "0" ]; then #user wants to see all data

curl -s https://chainapi.core.cloudchainsinc.com/api/v2.0/ticker | jq [.]

else #show only containing ticker in $1

curl -s https://chainapi.core.cloudchainsinc.com/api/v2.0/ticker | jq '[. | to_entries[] | select(.key | contains("'$input'")) | {(.key):(.value)}]'

fi
