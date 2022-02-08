#! /bin/bash

curl -s -u monero:monero --digest -X POST http://127.0.0.1:18085/get_transaction_pool -H 'Content-Type: application/json'