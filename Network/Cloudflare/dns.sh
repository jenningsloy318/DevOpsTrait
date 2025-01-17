#!/bin/bash

zone_name='lmyby.icu'
api_token='xxx'
zone_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "Authorization: Bearer ${api_token}" -H "Content-Type:application/json"| jq -r '.result[0].id' )

dev_record_id='bd96f7631eae46121f0ff58477335a14'
dev_record_new_ip='222.211.240.83'
curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${dev_record_id}" \
     -H "Authorization: Bearer ${api_token}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"dev.lmyby.icu","content":"'${dev_record_new_ip}'","ttl":300,"proxied":true}' | jq

dev6_record_id='9fbad66e185ac7e6af4fc4a5dbbd98c1'
dev6_record_id_new_ip='240e:39a:384:a8e0::1'
curl -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${dev6_record_id}" \
     -H "Authorization: Bearer ${api_token}" \
     -H "Content-Type: application/json" \
     --data '{"type":"AAAA","name":"dev6.lmyby.icu","content":"'${dev6_record_id_new_ip}'","ttl":300,"proxied":true}' | jq