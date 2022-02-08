#! /bin/bash

#set -x

input=$1

if [ ${input} == "0" ]; then #user wants to see all data

curl -s https://chainapi.core.cloudchainsinc.com/api/v2.0/history | jq .

else #show only containing ticker in $1

curl -s https://chainapi.core.cloudchainsinc.com/api/v2.0/history | jq '[.[] | (select(.to | contains("'$input'")))]'

fi