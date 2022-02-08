#! /bin/sh


access_token=
guid=
long_url=$1


curl -s -X POST \
 https://api-ssl.bitly.com/v4/bitlinks \
 -H 'Authorization: Bearer '${access_token}'' \
 -H 'Content-Type: application/json' \
 -d '{
 "group_guid": "'${guid}'",
 "long_url": "'${long_url}'"
}' \
 | jq '[. | {shortened_url: .link, long_url: .long_url,}]'
 
 
 