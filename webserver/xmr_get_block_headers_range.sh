#! /bin/bash

start_block=$1
end_block=$2

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_block_headers_range","params":{"start_height":'${start_block}',"end_height":'${end_block}'}}' -H 'Content-Type: application/json'

