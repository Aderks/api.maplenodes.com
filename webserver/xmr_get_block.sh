#! /bin/bash


#set -x


input=$1

if [[ ${input} =~ ^-?[0-9]+$ ]] ; then

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_block","params":{"height":'${input}'}}' -H 'Content-Type: application/json' 

else

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_block","params":{"hash":"'${input}'"}}' -H 'Content-Type: application/json'

fi

