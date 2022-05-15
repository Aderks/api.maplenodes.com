#! /bin/bash

#set -x
#Time UTC in Seconds
currentTime=$(date -u +%s)


#Graph Subgraph Indexer
indexer_id=$1
indexer_id1=$(echo $indexer_id | tr '[:upper:]' '[:lower:]')
indexer=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{indexer(id: \"'$indexer_id1'\") {createdAt url geoHash defaultDisplayName stakedTokens allocatedTokens unstakedTokens lockedTokens tokensLockedUntil allocationCount allocations { id createdAt } totalAllocationCount queryFeesCollected queryFeeRebates rewardsEarned indexerIndexingRewards delegatorIndexingRewards delegatedCapacity tokenCapacity availableStake delegatedTokens delegatorShares delegationExchangeRate indexingRewardCut delegatorQueryFees queryFeeCut delegatorParameterCooldown lastDelegationParameterUpdate forcedClosures totalReturn annualizedReturn stakingEfficiency indexingRewardEffectiveCut queryFeeEffectiveCut } } "}' https://gateway.thegraph.com/network`

indexer_ens=$(echo $indexer | jq -r .data.indexer.defaultDisplayName)

#Since Last Parameter Update
lastDelegationParameterUpdate=$(echo $indexer | jq -r .data.indexer.lastDelegationParameterUpdate)
lastParameterUpdateTimeStamp=`curl -s -X POST -H "Content-Type: application/json" -d '{ "query": "{blocks(where: {number: \"'$lastDelegationParameterUpdate'\"}) { number id timestamp} } "}' https://api.thegraph.com/subgraphs/name/senamakel/blocks | jq -r .data.blocks[].timestamp`

if [ -z $lastParameterUpdateTimeStamp ]; then
lastParameterUpdateTimeStamp=$(echo '0')
else
lastParameterUpdateTimeStamp=$(echo $lastParameterUpdateTimeStamp)
fi

timeLastParameterUpdate_formatted=$(date -u -d @$lastParameterUpdateTimeStamp)
lastParameterUpdateTimeElapsed=$(echo "$currentTime - $lastParameterUpdateTimeStamp" | bc)

function displaytime1 {
  local T=$lastParameterUpdateTimeElapsed
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%dd ' $D
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 )) && printf '%dm ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf '%ds' $S
}

displayTimeParameterUpdate=$(displaytime1)


#Cooldown Time Remaining
delegatorParameterCooldown=$(echo $indexer | jq -r .data.indexer.delegatorParameterCooldown)
parameterCooldownSeconds=$(echo "$delegatorParameterCooldown * 13" | bc -l | xargs printf %.0f) #13 block time
parameterCooldownTime=$(echo "$lastParameterUpdateTimeStamp + $parameterCooldownSeconds" | bc -l)
parameterCooldownTimeDifference=$(echo "$parameterCooldownTime - $currentTime" | bc -l)

function displaytime2 {
  local T=$parameterCooldownTimeDifference
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))  
  (( $D > 0 )) && printf '%dd ' $D
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 )) && printf '%dm ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf '%ds' $S
}

if [[ $parameterCooldownTimeDifference -le 0 ]];then
displayTimeCooldown=$(echo '0d 0h 0m 0s')
elif [ $currentTime -lt $parameterCooldownTime ];then
displayTimeCooldown=$(displaytime2)
else
displayTimeCooldown=$(echo '0d 0h 0m 0s')
fi


#Allocation Time
allocation=$(echo $indexer | jq -r .data.indexer.allocations[].id | sed -e "s/^0x//")
allocationCreatedAt=$(echo $indexer | jq -r .data.indexer.allocations[].createdAt)
timeLastAllocation=$(echo $allocationCreatedAt | tr " " "\n" | sort -nr | head -n 1)
timeFirstAllocation=$(echo $allocationCreatedAt | tr " " "\n" | sort -n | head -n 1)

if [ -z $timeLastAllocation ] || [ -z $timeFirstAllocation ]; then
timeLastAllocation=$(echo '0')
timeFirstAllocation=$(echo '0')
else
timeLastAllocation=$(echo $timeLastAllocation)
timeFirstAllocation=$(echo $timeFirstAllocation)
fi

timeLastAllocation_formatted=$(date -u -d @$timeLastAllocation)
allocationTimeElapsed=$(echo "$currentTime - $timeLastAllocation" | bc)
allocationTimeElapsedHr=$(echo "$allocationTimeElapsed / 3600" | bc -l)

function displaytime {
  local T=$allocationTimeElapsed
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%dd ' $D
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 )) && printf '%dm ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf '%ds' $S
}

displayTime=$(displaytime)

timeFirstAllocation_formatted=$(date -u -d @$timeFirstAllocation)
allocationTimeElapsed1=$(echo "$currentTime - $timeFirstAllocation" | bc)
allocationTimeElapsedHr1=$(echo "$allocationTimeElapsed1 / 3600" | bc -l)

function displaytime3 {
  local T=$allocationTimeElapsed1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%dd ' $D
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 )) && printf '%dm ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf '%ds' $S
}

displayTime3=$(displaytime3)


#Allocation pending reward
allocations_info=$(echo `curl -s -X GET https://api.maplenodes.com/graph/allocations/$indexer_id1`)

if [ "$allocations_info" == '[]' ]; then
total=0
else
total=$(echo $allocations_info | jq .[].pending_reward | awk '{s+=$1} END {print s}')
fi


#Total tokens allocated by indexer
allocatedTokens=$(echo $indexer | jq -r .data.indexer.allocatedTokens)
allocatedTokens1=$(echo "$allocatedTokens / 1000000000000000000" | bc -l | xargs printf %.2f)


#Staked tokens without delegates
stakedTokens=$(echo $indexer | jq -r .data.indexer.stakedTokens)
stakedTokens1=$(echo "$stakedTokens / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total indexer rewards after delegation share
indexerIndexingRewards=$(echo $indexer | jq -r .data.indexer.indexerIndexingRewards)
indexerIndexingRewards1=$(echo "$indexerIndexingRewards / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total rewards indexer + delegators
rewardsEarned=$(echo $indexer | jq -r .data.indexer.rewardsEarned)
rewardsEarned1=$(echo "$rewardsEarned / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total indexer query rewards
queryFeesCollected=$(echo $indexer | jq -r .data.indexer.queryFeesCollected)
queryFeesCollected1=$(echo "$queryFeesCollected / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total indexer query rebates
queryFeeRebates=$(echo $indexer | jq -r .data.indexer.queryFeeRebates)
queryFeeRebates1=$(echo "$queryFeeRebates / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total delegated towards indexer
delegatedTokens=$(echo $indexer | jq -r .data.indexer.delegatedTokens)
delegatedTokens1=$(echo "$delegatedTokens / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total delegator indexing rewards
delegatorIndexingRewards=$(echo $indexer | jq -r .data.indexer.delegatorIndexingRewards)
delegatorIndexingRewards1=$(echo "$delegatorIndexingRewards / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total delegator query rewards
delegatorQueryFees=$(echo $indexer | jq -r .data.indexer.delegatorQueryFees)
delegatorQueryFees1=$(echo "$delegatorQueryFees / 1000000000000000000" | bc -l | xargs printf %.2f)


#Total query rebates
totalQueryFeeRebates1=$(echo $queryFeeRebates1 + $delegatorQueryFees1 | bc -l | xargs printf %.2f)


#Total allowable stake indexer + delegators
tokenCapacity=$(echo $indexer | jq -r .data.indexer.tokenCapacity)
tokenCapacity1=$(echo "$tokenCapacity / 1000000000000000000" | bc -l | xargs printf %.2f)


#Indexer reward cut
indexingRewardCut=$(echo $indexer | jq -r .data.indexer.indexingRewardCut)
indexingRewardCut1=$(echo "$indexingRewardCut / 10000" | bc -l | xargs printf %.2f)
indexingRewardCut_decimal=$(echo "$indexingRewardCut / 1000000" | bc -l | xargs printf %.2f)
delegatorRewardCut1=$(echo 100 - $indexingRewardCut1 | bc -l)
delegatorRewardCut_decimal=$(echo 1 - $indexingRewardCut_decimal | bc -l | awk '{printf "%.2f\n", $1 + $2}')


#Indexer query cut
queryFeeCut=$(echo $indexer | jq -r .data.indexer.queryFeeCut)
queryFeeCut1=$(echo "$queryFeeCut / 10000" | bc -l | xargs printf %.2f)
delegatorQueryFeeCut1=$(echo 100 - $queryFeeCut1 | bc -l)


#GRT to USD price
grt_usd=`curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=the-graph&vs_currencies=usd" -H "accept: application/json" | jq '."the-graph" | {grt_usd: .usd} | .grt_usd'` 


#Allowable vs Allocated
allocation_difference=$(echo "$tokenCapacity1 - $allocatedTokens1" | bc -l | awk '{printf "%.2f\n", $1 + $2}')
allocation_percent=$(echo "($allocatedTokens1 / $tokenCapacity1) * 100"  | bc -l | xargs printf %.2f)


#Pending Rewards
pending_indexer_rewards=$(echo "${total} * ${indexingRewardCut_decimal}" | bc -l | xargs printf %.2f)
pending_delegator_rewards=$(echo "${total} * ${delegatorRewardCut_decimal}" | bc -l | xargs printf %.2f)


#Pending Rewards Rate Per Hour
pending_rewards_hr=$(echo $allocations_info | jq .[].pending_reward_rate | awk '{s+=$1} END {print s}')

if [ -z "$pending_rewards_hr" ]; then
pending_rewards_hr=0
else
:
fi

pending_rewards_hr_usd=$(echo "${grt_usd} * ${pending_rewards_hr}" | bc -l | xargs printf %.2f)
pending_indexer_rewards_hr=$(echo "${pending_rewards_hr} * ${indexingRewardCut_decimal}" | bc -l | xargs printf %.2f)
pending_indexer_rewards_hr_usd=$(echo "${grt_usd} * ${pending_indexer_rewards_hr}" | bc -l | xargs printf %.2f)
pending_delegator_rewards_hr=$(echo "${pending_rewards_hr} * ${delegatorRewardCut_decimal}" | bc -l | xargs printf %.2f)
pending_delegator_rewards_hr_usd=$(echo "${grt_usd} * ${pending_delegator_rewards_hr}" | bc -l | xargs printf %.2f)


#Indexing Reward Effective Cut
indexingRewardEffectiveCut=$(echo $indexer | jq -r .data.indexer.indexingRewardEffectiveCut)
indexingRewardEffectiveCut1=$(echo "$indexingRewardEffectiveCut * 100" | bc -l | xargs printf %.2f)

#Indexing Query Fee Effective Cut
queryFeeEffectiveCut=$(echo $indexer | jq -r .data.indexer.queryFeeEffectiveCut)
queryFeeEffectiveCut1=$(echo "$queryFeeEffectiveCut * 100" | bc -l | xargs printf %.2f)

#USD
pending_indexer_rewards_usd=$(echo "${grt_usd} * ${pending_indexer_rewards}" | bc -l | xargs printf %.2f)
pending_delegator_rewards_usd=$(echo "${grt_usd} * ${pending_delegator_rewards}" | bc -l | xargs printf %.2f)
pending_rewards_usd=$(echo "${grt_usd} * ${total}" | bc -l | xargs printf %.2f)
indexer_rewards_usd=$(echo "${grt_usd} * ${indexerIndexingRewards1}" | bc -l | xargs printf %.2f)
delegator_rewards_usd=$(echo "${grt_usd} * ${delegatorIndexingRewards1}" | bc -l | xargs printf %.2f)
total_rewards_usd=$(echo "${grt_usd} * ${rewardsEarned1}" | bc -l | xargs printf %.2f)
indexer_query_fees_usd=$(echo "${grt_usd} * ${queryFeesCollected1}" | bc -l | xargs printf %.2f)
indexer_query_rebates_usd=$(echo "${grt_usd} * ${queryFeeRebates1}" | bc -l | xargs printf %.2f)
delegator_query_fees_usd=$(echo "${grt_usd} * ${delegatorQueryFees1}" | bc -l | xargs printf %.2f)
allowable_stake_usd=$(echo "${grt_usd} * ${tokenCapacity1}" | bc -l | xargs printf %.2f)
allocated_stake_usd=$(echo "${grt_usd} * ${allocatedTokens1}" | bc -l | xargs printf %.2f)
allocation_difference_usd=$(echo "${grt_usd} * ${allocation_difference}" | bc -l | xargs printf %.2f)
indexer_stake_usd=$(echo "${grt_usd} * ${stakedTokens1}" | bc -l | xargs printf %.2f)
total_delegated_usd=$(echo "${grt_usd} * ${delegatedTokens1}" | bc -l | xargs printf %.2f)
total_query_fee_rebates_usd=$(echo "${grt_usd} * ${totalQueryFeeRebates1}" | bc -l | xargs printf %.2f)

result=$(
echo '{'
echo '"indexer":' '"'$indexer_id'"'','
echo '"indexer_name":' '"'$indexer_ens'"'','
echo '"total_allowable_stake":' $tokenCapacity1','
echo '"total_allowable_stake_usd":' $allowable_stake_usd','
echo '"total_allocated_stake":' $allocatedTokens1','
echo '"total_allocated_stake_usd":' $allocated_stake_usd','
echo '"allocation_difference":' $allocation_difference','
echo '"allocation_difference_usd":' $allocation_difference_usd','
echo '"allocation_percent":' $allocation_percent','
echo '"time_first_allocation":' '"'$timeFirstAllocation_formatted'"'','
echo '"time_lapsed_first_allocation":' '"'$displayTime3' ago"'','
echo '"time_last_allocation":' '"'$timeLastAllocation_formatted'"'','
echo '"time_lapsed_last_allocation":' '"'$displayTime' ago"'','
echo '"time_lapsed_last_allocation_raw":' $timeLastAllocation','
echo '"time_last_parameter_change":' '"'$timeLastParameterUpdate_formatted'"'','
echo '"time_lapsed_last_parameter_change":' '"'$displayTimeParameterUpdate' ago"'','
echo '"time_cooldown_remaining":' '"'$displayTimeCooldown'",'
echo '"pending_rewards":' $total','
echo '"pending_rewards_usd":' $pending_rewards_usd','
echo '"pending_rewards_hourly":' $pending_rewards_hr','
echo '"pending_rewards_hourly_usd":' $pending_rewards_hr_usd','
echo '"pending_rewards_indexer":' $pending_indexer_rewards','
echo '"pending_rewards_indexer_usd":' $pending_indexer_rewards_usd','
echo '"pending_rewards_indexer_hourly":' $pending_indexer_rewards_hr','
echo '"pending_rewards_indexer_hourly_usd":' $pending_indexer_rewards_hr_usd','
echo '"pending_rewards_delegator":' $pending_delegator_rewards','
echo '"pending_rewards_delegator_usd":' $pending_delegator_rewards_usd','
echo '"pending_rewards_delegator_hourly":' $pending_delegator_rewards_hr','
echo '"pending_rewards_delegator_hourly_usd":' $pending_delegator_rewards_hr_usd','
echo '"total_query_rebates":' $totalQueryFeeRebates1','
echo '"total_query_rebates_usd":' $total_query_fee_rebates_usd','
echo '"indexer_stake":' $stakedTokens1','
echo '"indexer_stake_usd":' $indexer_stake_usd','
echo '"indexer_reward_cut":' $indexingRewardCut1','
echo '"indexer_rewards":' $indexerIndexingRewards1','
echo '"indexer_rewards_usd":' $indexer_rewards_usd','
echo '"indexer_reward_effective_cut":' $indexingRewardEffectiveCut1','
echo '"indexer_query_cut":' $queryFeeCut1','
echo '"indexer_query_fees":' $queryFeesCollected1','
echo '"indexer_query_fees_usd":' $indexer_query_fees_usd','
echo '"indexer_query_rebates":' $queryFeeRebates1','
echo '"indexer_query_rebates_usd":' $indexer_query_rebates_usd','
echo '"indexer_query_fee_effective_cut":' $queryFeeEffectiveCut1','
echo '"total_delegated":' $delegatedTokens1','
echo '"total_delegated_usd":' $total_delegated_usd','
echo '"delegator_reward_cut":' $delegatorRewardCut1','
echo '"delegator_rewards":' $delegatorIndexingRewards1','
echo '"delegator_rewards_usd":' $delegator_rewards_usd','
echo '"delegator_query_cut":' $delegatorQueryFeeCut1','
echo '"delegator_query_fees":' $delegatorQueryFees1','
echo '"delegator_query_fees_usd":' $delegator_query_fees_usd','
echo '"total_rewards":' $rewardsEarned1','
echo '"total_rewards_usd":' $total_rewards_usd','
echo '"grt_usd":' $grt_usd''
echo '}')

echo $result | jq .
