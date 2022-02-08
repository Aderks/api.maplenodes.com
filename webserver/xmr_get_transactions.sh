#! /bin/bash

# tx_hashes = '["...","..."]'
tx_hashes=$1

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/get_transactions -d '{"txs_hashes":'$tx_hashes',"decode_as_json":true}' -H 'Content-Type: application/json'