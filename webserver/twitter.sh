#! /bin/sh


bearer_token=
search=$1
result_type=$2
tweet_count=$3


curl -s --request GET "https://api.twitter.com/1.1/search/tweets.json?q=${search}&result_type=${result_type}&count=${tweet_count}&tweet_mode=extended" \
 --header 'authorization: Bearer '${bearer_token}'' \
| jq '[.statuses[] | {tweeted_by: .user.name, "@user": .user.screen_name, tweet_time: .created_at, tweet: .full_text, retweet_count: .retweet_count, favorite_count: .favorite_count}]'