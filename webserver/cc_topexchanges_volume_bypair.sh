#! /bin/sh

ticker=$1
currency=$2
apikey=

curl -s "https://min-api.cryptocompare.com/data/top/exchanges?fsym=${ticker}&tsym=${currency}&api_key=${apikey}"
