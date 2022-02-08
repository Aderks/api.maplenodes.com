#! /bin/bash

#set -x

output=$(</services/trollbox/trollboxchat.json)


echo $output | sed 's/,$//g'

if [ `wc -l /services/trollbox/trollboxchat.json | awk '{print $1}'` -gt 201 ]; then
	sed -i 1,2d /services/trollbox/trollboxchat.json
	sed -i '1i [' /services/trollbox/trollboxchat.json
fi

echo "]"