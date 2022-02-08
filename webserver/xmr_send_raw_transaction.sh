#! /bin/bash

tx_as_hex=$1

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/send_raw_transaction -d '{"tx_as_hex":"'${tx_as_hex}'", "do_not_relay":false}' -H 'Content-Type: application/json'