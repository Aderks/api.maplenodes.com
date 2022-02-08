#! /bin/sh

tickers=$1
currency=$2
apikey=

curl -s "https://min-api.cryptocompare.com/data/pricemulti?fsyms=${tickers}&tsyms=${currency}&api_key=${apikey}"