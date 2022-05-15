#! /bin/bash

#set -x

graphSubgraphs=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{ subgraphs (first:1000, where: {active: true}) { currentVersion { subgraphDeployment { id createdAt ipfsHash originalName signalledTokens stakedTokens unsignalledTokens deniedAt } } displayName active } }"}' https://gateway.thegraph.com/network`

subgraphs_array=$(echo $graphSubgraphs | jq '[.data.subgraphs[] | (select(.currentVersion.subgraphDeployment.deniedAt | contains(0)))]')

echo $subgraphs_array | jq '. |=(group_by(.currentVersion.subgraphDeployment.id) | map(max_by(.createdAt)))' | jtc -w'[createdAt]:<>g:[-3]' -j
