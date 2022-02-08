#! /bin/sh

board=$1
thread=$2

curl -s "https://a.4cdn.org/${board}/thread/${thread}.json" | jq '[.posts[0] | {subject: .sub, total_replies: .replies, total_images: .images}]' | sed '/}/ s/$/,/' | tr -d ']'

curl -s "https://a.4cdn.org/${board}/thread/${thread}.json" | jq '[.posts[] | {name: .name, id: .id, time: .now, post_number: .no, reply_to: .resto, comment: .com}]' | tr -d '['