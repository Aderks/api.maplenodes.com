#! /bin/sh


apikey=
sport=$1
region=$2


curl -s "https://api.the-odds-api.com/v3/odds/?sport=${sport}&region=${region}&mkt=h2h&apiKey=${apikey}" | jq '[.data[] | {league: .sport_nice, teams: .teams,home_team: .home_team, source_site: .sites}]'



