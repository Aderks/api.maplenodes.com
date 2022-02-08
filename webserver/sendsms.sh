#! /bin/sh

account_sid=
auth_token=

your_number=$1
available_number=
message=$2

curl -s "https://api.twilio.com/2010-04-01/Accounts/${account_sid}/Messages.json" -X POST \
--data-urlencode "To=${your_number}" \
--data-urlencode "From=${available_number}" \
--data-urlencode "Body=${message}" \
-u "${account_sid}:${auth_token}" | jq '[. | {sms_id: .sid, date_created: .date_created, status: .status, error_code: .code, error_message: .message, error_help: .more_info}]'
