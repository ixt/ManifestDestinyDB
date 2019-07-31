#!/bin/bash
while read line; do 
    name=$(echo "$line" | jq -r '.name')
    echo "$line" | jq . | tee splitPermissions/$name.json
done < <( jq -c '.[]' otherData/permissionsDatabase.json)
while read line; do 
    name=$(echo "$line" | jq -r '.name')
    echo "$line" | jq . | tee splitPermissions/$name.json
done < <( jq -c '.[]' otherData/unknownPermissionDB.json)
