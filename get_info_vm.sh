#!/bin/bash
tenantid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
token=`curl -i -X POST -H "Accept: application/json" -d '{"auth":{"passwordCredentials":{"username":"xxxxxxx","password":"xxxxx"},"tenantId":"xxxxxxxxxxxxxxxxxxxxxxxxxxxx"}}' https://identity.han1.cloud.z.com/v2.0/tokens | grep -o 'id":"[^"]*' | head -1 | awk -F'"' '{print $3}'`
curl -i -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" https://compute.han1.cloud.z.com/v2/$tenantid/servers | grep -o 'id":"[^"]*' | awk -F'"' '{print $3}' > /tmp/uuid
for uuid in `cat /tmp/uuid`; do
        name=`curl -i -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" https://compute.han1.cloud.z.com/v2/$tenantid/servers/$uuid | grep -o 'instance_name_tag":"[^"]*' | awk -F'"' '{print $3}'`
        ipv4=`curl -i -X GET -H "Accept: application/json" -H "X-Auth-Token: $token" https://compute.han1.cloud.z.com/v2/$tenantid/servers/$uuid | grep -o 'version":4,"addr":"[^"]*' | awk -F'"' '{print $5}'`
        url="https://cp-vn.cloud.z.com/VPS/Detail/han1/$uuid"
        echo "$name,$ipv4,$url" >> result.csv
done
