#!/bin/bash

user=$1
message=$2

date=`date '+%s'`

output='{ "date": "'$date'", "alias": "'$user'", "message": "'$message'" }'

echo $output

output_json='{ "date": "'$date'", "alias": "'$user'", "message": "'$message'" },'

echo $output_json >> /services/trollbox/trollboxchat.json