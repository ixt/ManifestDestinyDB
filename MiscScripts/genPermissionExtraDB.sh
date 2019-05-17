#!/bin/bash

printf " " > unknownPermissionDB.json
while read permission; do
cat <<EOF >> unknownPermissionDB.json
{
  "description": "No description yet, this could be a misspelling or a permission created by the app itself",
  "name": "$permission",
  "protectionLevel": "unknown"
},
EOF
done < $1
sed -i '$s/,$//' unknownPermissionDB.json
