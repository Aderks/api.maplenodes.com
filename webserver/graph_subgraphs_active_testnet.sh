#! /bin/bash

#set -x

graphSubgraphs=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{ subgraphs (where: {active: true}) { currentVersion { subgraphDeployment { network { id } id createdAt ipfsHash originalName signalledTokens stakedTokens unsignalledTokens deniedAt } } displayName active } }"}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-goerli`

subgraphs_array=$(echo $graphSubgraphs | jq '[.data.subgraphs[] | (select(.currentVersion.subgraphDeployment.deniedAt | contains(0))) | (select(.currentVersion.subgraphDeployment.network.id | contains("gnosis")))]')

echo $subgraphs_array | jq '. |=(group_by(.currentVersion.subgraphDeployment.id) | map(max_by(.createdAt)))' | jtc -w'[createdAt]:<>g:[-3]' -j
