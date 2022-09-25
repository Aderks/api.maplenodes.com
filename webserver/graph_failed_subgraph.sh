#! /bin/bash

failed_subgraph=$1
failed_block=$2
indexer=$3

re='^[0-9]+$'

if ! [[ $failed_block =~ $re ]];then
failed_block_hex=`curl -s https://mainnet.infura.io/v3/xxx     -X POST     -H "Content-Type: application/json"     -d '{"jsonrpc":"2.0","method":"eth_getBlockByHash","params": ["'$failed_block'",false],"id":1}' | jq -r .result.number`
failed_block=$(printf '%d' $failed_block_hex)
else
failed_block=$failed_block
fi

epoch=`curl -s -X POST \
https://gateway.thegraph.com/network \
-H "Content-Type: application/json" \
-d @<(cat <<EOF
{
  "query":
    "{
      epoches(first: 1000, orderDirection: asc, orderBy: startBlock, where: {_change_block: {number_gte: $failed_block}}) {
        id
        startBlock
        endBlock
      }
    }"
}
EOF
) | jq .data.epoches[0]`

failed_start_block=$(echo $epoch | jq .startBlock)
failed_epoch=$(echo $epoch | jq -r .id)

failed_start_block_hex=$(printf '%x' $failed_start_block)
failed_start_block_hex1=$(echo 0x$failed_start_block_hex)

failed_start_block_hash=`curl -s https://mainnet.infura.io/v3/xxx     -X POST     -H "Content-Type: application/json"     -d '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params": ["'$failed_start_block_hex1'",false],"id":1}' | jq -r .result.hash`

result=$(
echo '{'
echo '"indexer":' '"'$indexer'"'','
echo '"failed_subgraph":' '"'$failed_subgraph'"'','
echo '"failed_epoch":' ''$failed_epoch''','
echo '"epoch_start_block":' ''$failed_start_block''','
echo '"epoch_start_block_hash":' '"'$failed_start_block_hash'"'
echo '}')

echo $result | jq .
