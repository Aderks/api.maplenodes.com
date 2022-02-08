#! /bin/bash

name=$1

curl -s http://127.0.0.1:8080/list_projects | jq '.result[] | select(.name=="'$name'") | {project_id: .name, project_active: .active, project_expires: .expires, api_tokens_used: .used_api_tokens, api_tokens_remaining: (.api_token_count - .used_api_tokens), api_tokens_total: .api_token_count}'
