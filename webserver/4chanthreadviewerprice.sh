#! /bin/bash

board=$1
thread=$2
ticker=$3
currency=$4
apikey=
time=$(curl -s "https://a.4cdn.org/${board}/thread/${thread}.json" | jq '.posts[0] | .time')

curl -s "https://min-api.cryptocompare.com/data/pricehistorical?fsym=${ticker}&tsyms=${currency}&ts=${time}&api_key=${apikey}" | jq '[.]' | sed '/]/ s/$/,/' | tr -d ']'

curl -s "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=${ticker}&tsyms=BTC&api_key=${apikey}" | jq '. | {percent_change_24h: .DISPLAY.'"${ticker}"'.BTC.CHANGEPCT24HOUR}' | sed '/}/ s/$/,/'

curl -s "https://a.4cdn.org/${board}/thread/${thread}.json" | jq '.posts[0] | {subject: .sub, total_replies: .replies, total_images: .images}' | sed '/}/ s/$/,/'

curl -s "https://a.4cdn.org/${board}/thread/${thread}.json" | jq '[.posts[] | {name: .name, id: .id, time: .now, post_number: .no, reply_to: .resto, comment: .com}]' | tr -d '['