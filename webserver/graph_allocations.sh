#! /bin/bash

#set -x

#Time UTC in Seconds
currentTime=$(date -u +%s)

#Graph Subgraph Indexer
indexer_id=$1
indexer_id1=$(echo $indexer_id | tr '[:upper:]' '[:lower:]')
indexer=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexer(id: \"'$indexer_id1'\") { allocationCount allocations { id createdAt subgraphDeployment { id originalName} } } } "}' https://gateway.thegraph.com/network`

allocationCount=$(echo $indexer | jq -r .data.indexer.allocationCount) 

allocation=$(echo $indexer | jq -r .data.indexer.allocations[].id | sed -e "s/^0x//")

#Allocation Pending Reward Loop
total=0
i=0

result=$(echo '['''

for allocation in $allocation
do

	reward=`curl -s -k http://192.168.50.66:8545 \
	  -H 'content-type: application/json' \
	  --data-binary '{"jsonrpc":"2.0","id":1,"method":"eth_call","params":[{"from":"0x0000000000000000000000000000000000000000","data":"0x79ee54f7000000000000000000000000'$allocation'","to":"0x9ac758ab77733b4150a901ebd659cbf8cb93ed66"},"latest"]}'   \
	  --compressed|jq -r '.result'| tr a-z A-Z | sed -e "s/^0X//" | xargs -I % echo "ibase=16; scale=18;" %|bc`
	reward2=$(echo "$reward / 1000000000000000000" | bc -l | xargs printf %.2f)
	total=$(echo "$reward2 + $total" | bc -l | xargs printf %.2f)

	allocationCreatedAt=$(echo $indexer | jq -r .data.indexer.allocations[$i].createdAt)
	date=$(echo $allocationCreatedAt)
	((i=i+1))

	allocationTimeElapsed=$(echo "$currentTime - $allocationCreatedAt" | bc)
	allocationTimeElapsedHr=$(echo "$allocationTimeElapsed / 3600" | bc -l | xargs printf %.2f)
	timeelapsed=$(echo $allocationTimeElapsedHr)

	pending_rewards_hr=$(echo "${reward2} / ${timeelapsed}" | bc -l | xargs printf %.2f)

	echo '{''' '"'""id""'"': '"'""0x$allocation""'"' ','''
	echo '"'""pending_reward""'"':'' $reward2 ','''
	echo '"'""created_at""'"':'' $date ','''
	echo '"'""time_elapsed""'"':'' $timeelapsed ','''
	echo '"'""pending_reward_rate""'"':'' $pending_rewards_hr '},'''

done

echo ']'
)

echo $result | sed -zr 's/,([^,]*$)/\1/' | jq .
