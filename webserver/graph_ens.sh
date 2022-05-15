#! /bin/bash

#Graph Subgraph Indexer
indexer_id=$1
indexer_id1=$(echo $indexer_id | tr '[:upper:]' '[:lower:]')

tokenLock=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{tokenLockWallet(id: \"'$indexer_id1'\") { id beneficiary } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/token-distribution`
beneficiary=$(echo $tokenLock | jq -r .data.tokenLockWallet.beneficiary)

graphAccount=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{graphAccount(id: \"'$beneficiary'\") { defaultDisplayName } } "}' https://gateway.thegraph.com/network`
indexer_ens=$(echo $graphAccount | jq -r .data.graphAccount.defaultDisplayName)

result=$(
echo '{'
echo '"indexer":' '"'$indexer_id1'",'
echo '"indexer_ens":' '"'$indexer_ens'",'
echo '"beneficiary_address":' '"'$beneficiary'"'
echo '}')

echo $result | jq .
