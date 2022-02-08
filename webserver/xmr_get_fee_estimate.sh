#! /bin/bash

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_fee_estimate"}' -H 'Content-Type: application/json' 