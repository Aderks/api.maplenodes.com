#! /bin/bash

indexers=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexers(first: 1000, where: {stakedTokens_gte: \"'100000000000000000000000'\"}) {id defaultDisplayName queryFeesCollected queryFeeRebates delegatorQueryFees tokenCapacity stakedTokens} } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-mainnet`

echo $indexers | jq '[.data.indexers[] |
.queryFeeRebates |= tonumber / 1000000000000000000 |
.delegatorQueryFees |= tonumber / 1000000000000000000 |
.queryFeesCollected |= tonumber / 1000000000000000000 |
.tokenCapacity |= tonumber / 1000000000000000000 |
.stakedTokens |= tonumber / 1000000000000000000 |
.totalFeeRebates = .queryFeeRebates + .delegatorQueryFees |
if .queryFeesCollected == 0 then .revenueSharePerformance = 0 else .revenueSharePerformance = (.totalFeeRebates / .queryFeesCollected) * 100 end |
if .stakedTokens == 0 then .revenueStakePerformance = 0 else .revenueStakePerformance = (.totalFeeRebates / .stakedTokens) end]'
