#! /bin/sh

ticker=$1
apikey=

curl -s "https://min-api.cryptocompare.com/data/top/volumes?tsym=${ticker}&api_key=${apikey}"