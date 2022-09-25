#! /bin/bash

#set -x

indexers=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexers(first: 1000) { id defaultDisplayName indexingRewardEffectiveCut queryFeeEffectiveCut stakedTokens delegatedTokens allocatedTokens } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-goerli`

#indexers_array=$(echo $indexers | jq '[.data.indexers[] | .["indexer"] = .id | .["indexer_name"] = .defaultDisplayName | del(.id, .defaultDisplayName)]') 
echo $indexers | jq '[.data.indexers[] |
.allocatedTokens |= tonumber / 1000000000000000000 | 
.delegatedTokens |= tonumber / 1000000000000000000 |
.indexingRewardEffectiveCut |= tonumber * 100 |
.queryFeeEffectiveCut |= tonumber * 100 |
.stakedTokens |= tonumber / 1000000000000000000 ]'
