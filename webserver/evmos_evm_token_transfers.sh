#! /bin/bash

transactions=`curl -s -X GET 'https://evm.evmos.org/api?module=account&action=tokentx&address='$1''`

echo $transactions | jq -S '[.result[] |
del(.blockHash, .confirmations, .contractAddress, .cumulativeGasUsed, .gas, .logIndex, .nonce, .transactionIndex, .tokenName, .tokenDecimal) |
.gasPrice |= tonumber / 1000000000000000000 |
.gasUsed |= tonumber |
.blockNumber |= tonumber |
if has("value") == true then .value |= tonumber / 1000000 else .value = .value end |
.timeStamp |= tonumber |
.transactionFee = .gasPrice * .gasUsed |
.timeStamp |= (strftime("%Y-%m-%dT%H:%M:%SZ")) |
.feeDenomination = "evmos"|
.valueDenomination = .tokenSymbol]'
