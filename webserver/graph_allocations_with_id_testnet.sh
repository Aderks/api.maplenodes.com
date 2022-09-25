#! /bin/bash

#set -x

#Time UTC in Seconds
currentTime=$(date -u +%s)

#Graph Subgraph Indexer
indexer_id=$1

indexer_id1=$(echo $indexer_id | tr '[:upper:]' '[:lower:]')
indexer=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexer(id: \"'$indexer_id1'\") { allocationCount allocations { id createdAt allocatedTokens createdAtEpoch subgraphDeployment { versions (first: 1) { subgraph { currentVersion { subgraph { displayName } } } } id originalName ipfsHash deniedAt } } } graphNetworks { currentEpoch } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-goerli`

allocationCount=$(echo $indexer | jq -r .data.indexer.allocationCount) 

currentEpoch=$(echo $indexer | jq -r .data.graphNetworks[].currentEpoch)

allocation=$(echo $indexer | jq -r .data.indexer.allocations[].id | sed -e "s/^0x//")

#Allocation Pending Reward Loop
total=0
i=0

result=$(echo '['''

for allocation in $allocation
do

  #reward=`curl -s -k http://127.0.0.1:8545 \
  #  -H 'content-type: application/json' \
  #  --data-binary '{"jsonrpc":"2.0","id":1,"method":"eth_call","params":[{"from":"0x0000000000000000000000000000000000000000","data":"0x79ee54f7000000000000000000000000'$allocation'","to":"0x9ac758ab77733b4150a901ebd659cbf8cb93ed66"},"latest"]}'   \
  #  --compressed|jq -r '.result'| tr a-z A-Z | sed -e "s/^0X//" | xargs -I % echo "ibase=16; scale=18;" %|bc`
  #reward2=$(echo "$reward / 1000000000000000000" | bc -l | xargs printf %.2f)
  #total=$(echo "$reward2 + $total" | bc -l | xargs printf %.2f)

  allocationCreatedAt=$(echo $indexer | jq -r .data.indexer.allocations[$i].createdAt)
  date=$(echo $allocationCreatedAt)

  allocationSubgraphId=$(echo $indexer | jq -r .data.indexer.allocations[$i].subgraphDeployment.id)
  allocationSubgraphId1=$(echo $allocationSubgraphId)

  allocationDisplayName=$(echo $indexer | jq -r .data.indexer.allocations[$i].subgraphDeployment.versions[].subgraph.currentVersion.subgraph.displayName)
  allocationDisplayName1=$(echo $allocationDisplayName)

  allocationSubgraphIPFS=$(echo $indexer | jq -r .data.indexer.allocations[$i].subgraphDeployment.ipfsHash)
  allocationSubgraphIPFS1=$(echo $allocationSubgraphIPFS)

  allocatedTokens=$(echo $indexer | jq -r .data.indexer.allocations[$i].allocatedTokens)
  allocatedTokens1=$(echo "$allocatedTokens / 1000000000000000000" | bc -l | xargs printf %.2f)

  allocationCreatedAtEpoch=$(echo $indexer | jq -r .data.indexer.allocations[$i].createdAtEpoch)
  allocationCreatedAtEpoch1=$(echo $allocationCreatedAtEpoch)
  activeEpochs=$(echo $currentEpoch - $allocationCreatedAtEpoch1 | bc -l)

  allocationDeniedAt=$(echo $indexer | jq -r .data.indexer.allocations[$i].subgraphDeployment.deniedAt)
  allocationDeniedAt1=$(echo $allocationDeniedAt)

  ((i=i+1))

  allocationTimeElapsed=$(echo "$currentTime - $allocationCreatedAt" | bc)
  allocationTimeElapsedHr=$(echo "$allocationTimeElapsed / 3600" | bc -l | xargs printf %.2f)
  timeelapsed=$(echo $allocationTimeElapsedHr)

  #pending_rewards_hr=$(echo "${reward2} / ${timeelapsed}" | bc -l | xargs printf %.2f)

  echo '{''' '"'""id""'"': '"'""0x$allocation""'"' ','''
  echo '"'""pending_reward""'"':'' 0 ','''
  echo '"'""created_at""'"':'' $date ','''
  echo '"'""time_elapsed""'"':'' $timeelapsed ','''
  echo '"'""pending_reward_rate""'"':'' 0 ','''
  echo '"'""subgraph_id""'"':'' '"'""$allocationSubgraphId1'"'"" ','''
  echo '"'""subgraph_ipfs""'"':'' '"'""$allocationSubgraphIPFS1'"'"" ','''
  echo '"'""subgraph_name""'"':'' '"'""$allocationDisplayName1'"'"" ','''
  echo '"'""allocated_tokens""'"':'' '"'""$allocatedTokens1'"'"" ','''
  echo '"'""created_at_epoch""'"':'' $allocationCreatedAtEpoch1 ','''
  echo '"'""denied_at""'"':'' $allocationDeniedAt1 ','''
  echo '"'""active_epochs""'"':'' $activeEpochs '},'''

done

echo ']'
)

echo $result | sed -zr 's/,([^,]*$)/\1/' | jq .
