#! /bin/bash

data=`curl -s "https://rpc-1.evmos.nodes.guru/tx_search?query=\"message.sender='$1'\"&prove=true&per_page=100&page=$2"`

hash_list=$(echo $data | jq -r .result.txs[].hash)

x=0

result=$(echo '['''

for hash_list in $hash_list
do

        hash=$(echo $data | jq -r '.result.txs['$x'].hash')
        height=$(echo $data | jq -r '.result.txs['$x'].height')

        timestamp=`curl -s https://rest.bd.evmos.org:1317/cosmos/tx/v1beta1/txs/$hash | jq -r .tx_response.timestamp`

        log=$(echo $data | jq -r '.result.txs['$x'].tx_result.log')
        event=$(echo $log | jq -r .[].type)

                i=0

                for event in $event
                do

                        tx_type=$(echo $log | jq -r '.['$i'].events[] | select(.type=="message") | .attributes[]| select(.key=="action") | .value' \
                                            | sed 's/^.*Msg/Msg/' \
                                            | sed 's/Msg//' \
                                            | sed 's/\([^[:blank:]]\)\([[:upper:]]\)/\1 \2/g')


                        if [[ "$tx_type" == 'Delegate' ]]; then

                        amount=$(echo $log | jq -r 'first(.['$i'].events[] | select(.type=="delegate") | .attributes[] | select(.key=="amount") | .value | sub("aevmos"; "") | tonumber/1000000000000000000)' \
                                           | xargs printf %.18f)

                        auto_claim_reward=$(echo $log | jq -r 'first(.['$i'].events[] | select(.type=="transfer") | .attributes[] | select(.key=="amount") | .value | sub("aevmos"; "") | tonumber/1000000000000000000)' \
                                           | xargs printf %.18f)

                        else
                        amount=$(echo $log | jq -r 'first(.['$i'].events[] | .attributes[] | select(.key=="amount") | .value | sub("aevmos"; "") | tonumber/1000000000000000000)' \
                                           | xargs printf %.18f)

                        auto_claim_reward=0.000000000000000000

                        fi

                        fee_check=$(echo $data | jq -r '.result.txs['$x'].tx_result.events[].attributes[] | select(.key=="ZmVl") | .value')

                        if [[ "$fee_check" == 'null' ]]; then
                          fee="0.000000000000000000"
                        else
                          fee=$(echo $data | jq -r '.result.txs['$x'].tx_result.events[].attributes[] | select(.key=="ZmVl") | .value | @base64d | sub ("aevmos"; "") | tonumber/1000000000000000000' \
                                                        | xargs printf %.18f)
                        fi

                        total=$(echo "$amount + $auto_claim_reward" | bc -l | xargs printf %.18f)

                        ((i=i+1))

                        echo '{'
                        echo '"block_height":' ''$height','
                        echo '"tx_hash":' '"'$hash'",'
                        echo '"tx_type":' '"'$tx_type'",'
                        echo '"amount":' '"'$amount'",'
                        echo '"auto_claim_reward":' '"'$auto_claim_reward'",'
                        echo '"total":' '"'$total'",'
                        echo '"fee":' '"'$fee'",'
                        echo '"denomination":' '"evmos",'
                        echo '"time_stamp":' '"'$timestamp'"'
                        echo '},'

                done

        ((x=x+1))

done

echo ']'
)

echo $result | sed -zr 's/,([^,]*$)/\1/' | jq .
