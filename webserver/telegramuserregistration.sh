#! /bin/bash

#set -x

username=$1
password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c10)

search=$(cat /services/telegram/userlist.json | grep -s -w "${username}")

if [[ "${username}" =~ [^a-zA-Z0-9\ ] ]]; then

echo '{ "message": "only alphanumeric usernames are allowed" }'
exit;

elif [[ "${search}" == *"${username}"* ]]; then

echo '{ "message": "user exists already, please try a different username" }'
exit;

fi

output=${username}:${password}

echo $output | tee -a /services/telegram/userlist.json > /dev/null
 
echo '{ "user_authorization": "'${output}'" }'
