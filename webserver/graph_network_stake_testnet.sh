#! /bin/bash

graphNetwork=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{graphNetworks { totalTokensStaked totalDelegatedTokens } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-goerli`

indexerStake=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalTokensStaked)
indexerStake1=$(echo "$indexerStake / 1000000000000000000" | bc -l | xargs printf %.2f)

delegatedStake=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalDelegatedTokens)
delegatedStake1=$(echo "$delegatedStake / 1000000000000000000" | bc -l | xargs printf %.2f)

totalStake1=$(echo $indexerStake1 + $delegatedStake1 | bc -l)

echo $totalStake1
