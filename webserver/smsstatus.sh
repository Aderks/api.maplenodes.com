#! /bin/sh

account_sid=
auth_token=

sid=$1


curl -s "https://api.twilio.com/2010-04-01/Accounts/${account_sid}/SMS/Messages/${sid}.json" -X GET \
-u "${account_sid}:${auth_token}" | jq '[. | {sms_id: .sid, date_created: .date_created, date_updated: .date_updated, status: .status, date_sent: .date_sent}]'