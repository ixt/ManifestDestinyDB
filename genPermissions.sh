#!/bin/bash
#./AndroidPermissionsInAJSONPlease.sh 
while read permission; do 
    name=$(echo "$permission" | cut -d, -f1 | sed -e "s/\"//g")
    level=$(echo "$permission" | cut -d, -f2 )
    description=$(echo "$permission" | cut -d, -f3- | sed -e "s/^\"//" -e "s/\"$//")
    lessername=$(echo $name | tr '[:upper:]' '[:lower:]')
    echo "Generating $lessername.md" 
    mkdir "output/permissions/$lessername" 2>/dev/null
    cat <<EOF > "output/permissions/$lessername/_index.md"
---
title: "$name"
protectionlevel: "$level"
description: "$description"
---
{{< permission "$name" >}}
EOF

done < <(jq -r ".[] | [.name, .protectionLevel, .description ] | @csv" otherData/permissionsDatabase.json)

while read name; do
    lessername=$(echo $name | tr '[:upper:]' '[:lower:]')
    description="This permission has no definition so far"
    if [[ $( echo "$name" | grep -i -q "c2d" ) ]]; then
        description="This is a permission used by an app to allow messages to be sent from a server to the android device"
    fi
    if [[ ! -e "output/permissions/$lessername/_index.md" ]]; then 
        echo "Generating $lessername.md" 
        mkdir "output/permissions/$lessername" 2>/dev/null
        cat <<EOF > "output/permissions/$lessername/_index.md"
---
title: "$name"
protectionlevel: "unknown"
description: "$description"
---

EOF
    fi
done < <(jq -r ".permissions[]" manifests/*.json | sort -u | sed -e "/com.sec.spp.permission.TOKEN/d")
