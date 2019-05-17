#!/bin/bash
echo "---" > output/permissions.md
echo "title: \"Permissions\"" >> output/permissions.md
echo "---" >> output/permissions.md
while read permission; do
    per=$(echo "$permission" | tr '[:upper:]' '[:lower:]')
    echo "[$permission](/permissions/$per)  " >> output/permissions.md
done < <(jq -r ".[] | .name" otherData/permissionsDatabase.json)
