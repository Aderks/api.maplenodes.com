#! /bin/bash

ipfs=$1

curl -s --max-time 5 https://api.thegraph.com/ipfs/api/v0/cat?arg=$ipfs > /dev/null
if [ $? -eq 28 ];
then 
  result=$(
  echo '{'
  echo '"ipfs":' '"'$ipfs'",'
  echo '"trace_required":' "null"
  echo '}')
  echo $result | jq .
else
  manifest=`curl -s https://api.thegraph.com/ipfs/api/v0/cat?arg=$ipfs`
  if [[ $(echo $manifest | grep callHandler) || $(echo $manifest | grep blockHandler) ]]; then
    result=$(
    echo '{'
    echo '"ipfs":' '"'$ipfs'",'
    echo '"trace_required":' "true"
    echo '}')
    echo $result | jq .
  else
    result=$(
    echo '{'
    echo '"ipfs":' '"'$ipfs'",'
    echo '"trace_required":' "false"
    echo '}')
    echo $result | jq .
  fi
fi