#! /bin/sh

ticker=$1
currency=$2
apikey=

curl -s "https://min-api.cryptocompare.com/data/price?fsym=${ticker}&tsyms=${currency}&api_key=${apikey}"