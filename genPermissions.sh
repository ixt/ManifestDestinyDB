#!/bin/bash
#./AndroidPermissionsInAJSONPlease.sh 
while read permission; do 
    name=$(echo "$permission" | cut -d, -f1 | sed -e "s/\"//g")
    level=$(echo "$permission" | cut -d, -f2 )
    description=$(echo "$permission" | cut -d, -f3- | sed -e "s/^\"//" -e "s/\"$//")
    echo "Generating $name.md" 
    cat <<EOF > output/permissions/$name.md
---
title: "$name"
protectionlevel: $level
---

$description
EOF

done < <(jq -r ".[] | [.name, .protectionLevel, .description ] | @csv" permissionsDatabase.json)

while read name; do
    if [[ ! -e "output/permissions/$name.md" ]]; then 
        cat <<EOF > output/permissions/$name.md
---
title: "$name"
protectionlevel: "unknown"
---

This permission has no definition so far
EOF
    fi
done < <(jq -r ".permissions[]" manifests/*.json | sort -u | sed -e "/com.sec.spp.permission.TOKEN/d")
