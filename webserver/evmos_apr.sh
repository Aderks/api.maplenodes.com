#! /bin/bash

bonded_tokens=`curl -s "https://rest.bd.evmos.org:1317/cosmos/staking/v1beta1/pool" | jq -r .pool.bonded_tokens`
bonded_tokens1=$(echo "$bonded_tokens / 1000000000000000000" | bc -l | xargs printf %.2f)
circulating_supply=`curl -s "https://rest.bd.evmos.org:1317/evmos/inflation/v1/circulating_supply" | jq -r .circulating_supply.amount`
circulating_supply1=$(echo "$circulating_supply / 1000000000000000000" | bc -l | xargs printf %.2f)
staking_rewards=`curl -s "https://rest.bd.evmos.org:1317/evmos/inflation/v1/params" | jq -r .params.inflation_distribution.staking_rewards`
epoch_mint_provision=`curl -s "https://rest.bd.evmos.org:1317/evmos/inflation/v1/epoch_mint_provision" | jq -r .epoch_mint_provision.amount`
evmos_usd=`curl -s -X GET "https://api.coingecko.com/api/v3/simple/price?ids=evmos&vs_currencies=usd" -H "accept: application/json" | jq '."evmos" | {evmos_usd: .usd} | .evmos_usd'` 
commission=0.05

apr=$(echo "(1-$commission)*((365*$epoch_mint_provision*$staking_rewards)/$bonded_tokens)*100" | bc -l | xargs printf %.2f)

result=$(echo

echo '{'
echo '"evmos_apr":' ''$apr','
echo '"circulating_supply":' ''$circulating_supply1','
echo '"bonded_tokens":' ''$bonded_tokens1','
echo '"evmos_usd":' ''$evmos_usd''
echo '}'
)

echo $result | jq .
