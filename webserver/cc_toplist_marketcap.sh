#! /bin/sh

limit=$1
currency=$2
apikey=

curl -s "https://min-api.cryptocompare.com/data/top/mktcapfull?limit=${limit}&tsym=${currency}&api_key=${apikey}"