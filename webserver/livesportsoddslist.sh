#! /bin/sh


apikey=
active=$1


curl -s "https://api.the-odds-api.com/v3/sports/?all=${active}&apiKey=${apikey}" | jq '[.data[] | {league: .title, in_season: .active, id_key: .key}]'