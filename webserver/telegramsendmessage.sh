#! /bin/bash

#set -x

api_token=
chat_id=
authorized_user=$1
message=$2

output=$(cat /services/telegram/userlist.json | grep -Fx "${authorized_user}")
username=$(echo $output | cut -f1 -d":")

if [[ $authorized_user != $output ]]; then

echo '{ "message": "incorrect user authorization" }'

elif [[ $authorized_user == $output ]]; then

curl -s -X POST \
     -H 'Content-Type: application/json' \
     -d '{"chat_id": "'${chat_id}'", "text": "('"${username}"') - '"$message"'", "disable_notification": true}' \
     https://api.telegram.org/bot${api_token}/sendMessage | jq '.result | {date: .date, message: .text}'

fi
