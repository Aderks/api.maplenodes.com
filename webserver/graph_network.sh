#! /bin/bash

graphNetwork=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{graphNetworks { totalTokensAllocated totalTokensStaked totalSupply totalDelegatedTokens } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-mainnet`

indexerStake=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalTokensStaked)
indexerStake1=$(echo "$indexerStake / 1000000000000000000" | bc -l | xargs printf %.2f)

delegatedStake=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalDelegatedTokens)
delegatedStake1=$(echo "$delegatedStake / 1000000000000000000" | bc -l | xargs printf %.2f)

totalStake1=$(echo $indexerStake1 + $delegatedStake1 | bc -l)

allocatedStake=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalTokensAllocated)
allocatedStake1=$(echo "$allocatedStake / 1000000000000000000" | bc -l | xargs printf %.2f)

totalSupply=$(echo $graphNetwork | jq -r .data.graphNetworks[].totalSupply)
totalSupply1=$(echo "$totalSupply / 1000000000000000000" | bc -l | xargs printf %.2f)

result=$(
echo '{'
echo '"total_supply":' $totalSupply1','
echo '"indexer_stake":' $indexerStake1','
echo '"delegated_stake":' $delegatedStake1','
echo '"total_tokens_staked":' $totalStake1','
echo '"allocated_stake":' $allocatedStake1
echo '}')

echo $result | jq .
