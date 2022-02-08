#! /bin/sh

board=$1

curl -s "https://a.4cdn.org/${board}/catalog.json" | jq '[.[].threads[] | {number: .no, time: .now, subject: .sub, original_post: .com, replies: .replies, images: .images}]'