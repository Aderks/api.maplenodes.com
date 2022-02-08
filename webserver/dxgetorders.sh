#! /bin/bash

maker=$1
taker=$2

if [ ${maker} == "0" ] || [ ${taker} == "0" ]; then #user wants to see all data

curl -s http://chainapi.core.cloudchainsinc.com/api/v2.0/dxgetorders | jq [.]

else #show only containing ticker in $1

curl -s http://chainapi.core.cloudchainsinc.com/api/v2.0/dxgetorders | jq '[.[] | (select(.maker | contains("'$maker'"))) | (select(.taker| contains("'$taker'")))]'

fi
