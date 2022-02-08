#! /bin/sh

currency1=$1
currency2=$2
apikey=

curl -s "https://free.currconv.com/api/v7/convert?q=${currency1}_${currency2}&compact=ultra&apiKey=${apikey}"