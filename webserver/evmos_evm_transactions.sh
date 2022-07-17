#! /bin/bash

transactions=`curl -s -X GET 'https://evm.evmos.org/api?module=account&action=txlist&address='$1''`

echo $transactions | jq -S '[.result[] |
del(.blockHash, .confirmations, .contractAddress, .cumulativeGasUsed, .gas, .isError, .nonce, .transactionIndex, .txreceipt_status) |
.gasPrice |= tonumber / 1000000000000000000 |
.gasUsed |= tonumber |
.blockNumber |= tonumber |
.value |= tonumber / 1000000000000000000 |
.timeStamp |= tonumber |
.transactionFee = .gasPrice * .gasUsed |
.timeStamp |= (strftime("%Y-%m-%dT%H:%M:%SZ")) |
.feeDenomination = "evmos" |
.valueDenomination = "evmos"]'
