#! /bin/bash

#set -x

indexers=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexers(first: 500) { id stakedTokens queryFeeRebates queryFeesCollected defaultDisplayName } } "}' https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-mainnet`

indexer=$(echo $indexers | jq -r .data.indexers[].id)

i=0
result=$(echo '['''

for indexer in $indexer
do

	#Total indexer query rewards
	queryFeesCollected=$(echo $indexers | jq -r .data.indexers[$i].queryFeesCollected)
	if [ $queryFeesCollected == 0 ]; then
		queryFeesCollected1=0
	else
		queryFeesCollected1=$(echo "$queryFeesCollected / 1000000000000000000" | bc -l | xargs printf %.2f)
	fi


	#Total indexer query rebates
	queryFeeRebates=$(echo $indexers | jq -r .data.indexers[$i].queryFeeRebates)
	if [ $queryFeeRebates == 0 ]; then
		queryFeeRebates1=0
	else
		queryFeeRebates1=$(echo "$queryFeeRebates / 1000000000000000000" | bc -l | xargs printf %.2f)
	fi
	
	#Revenue Share Performance RShP = queryRebates / queryFees
	if [ $queryFeeRebates == 0 ]; then
		RShP=0
	else
		RShP=$(echo "$queryFeeRebates1 / $queryFeesCollected1" | bc -l | xargs printf %.2f)
	fi

	#Total indexer stake
	stakedTokens=$(echo $indexers | jq -r .data.indexers[$i].stakedTokens)
	if [ $stakedTokens == 0 ]; then
		stakedTokens1=0
	else
		stakedTokens1=$(echo "$stakedTokens / 1000000000000000000" | bc -l | xargs printf %.2f)
	fi

	#Revenue Stake Performance RStE = queryRebates / stakedTokens
	if [ $queryFeeRebates == 0 ]; then
		RStE=0
	elif [ $stakedTokens == 0 ]; then
		RStE=0
	else
		RStE=$(echo "$queryFeeRebates1 / $stakedTokens1" | bc -l | xargs printf %.8f)
	fi

	indexer_ens=$(echo $indexers | jq .data.indexers[$i].defaultDisplayName)

	((i=i+1))

	echo '{''' '"'""indexer""'"': '"'""$indexer""'"'','''
	echo '"indexer_ens":' $indexer_ens','
	echo '"indexer_stake":' $stakedTokens1','
	echo '"indexer_query_fees":' $queryFeesCollected1','
	echo '"indexer_query_rebates":' $queryFeeRebates1','
	echo '"revenue_share_performance":' $RShP','
	echo '"revenue_stake_performance":' $RStE' },'''

done

echo ']'
)

echo $result | sed -zr 's/,([^,]*$)/\1/' | jq .