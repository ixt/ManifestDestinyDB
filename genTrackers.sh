#!/bin/bash
while read tracker; do
    url=$(echo $tracker | tr '[:upper:]' '[:lower:]' )
    printf "Generating $url/_index.md \n"
    mkdir "output/trackers/$url" 2>/dev/null
cat <<EOF > "output/trackers/$url/_index.md"
---
title: "${tracker//-/ }"
---
    
EOF
done < <(jq -r .trackers[] manifests/* | sort -u | sed -e "s/ /-/g")
