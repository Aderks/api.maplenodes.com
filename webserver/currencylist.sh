#! /bin/sh


apikey=

curl -s "https://free.currconv.com/api/v7/currencies?apiKey=${apikey}" | jq '.results | map(del (.currencySymbol))'