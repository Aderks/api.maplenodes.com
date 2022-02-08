#! /bin/bash

#set -x

graphSubgraphs=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{subgraphDeployments { id signalledTokens unsignalledTokens stakedTokens originalName indexingRewardAmount createdAt ipfsHash} } "}' https://gateway.network.thegraph.com/network`

subgraphs_array=$(echo $graphSubgraphs | jq -r .data.subgraphDeployments)


echo $subgraphs_array | jq .
