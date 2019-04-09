#!/bin/bash
while read connection; do
    connectionname=$(echo "${connection}" | cut -d"," -f1 | sed -e "s/\"//g")
    if egrep -q "^N/A" <<< "$connectionname"; then
        name=$(printf "$connection" | sed "s/\"//g" | cut -d"," -f2 )
    else
        name=$(printf "$connection" | sed "s/\"//g" | cut -d"," -f1 | sed "s/\.$//g")
    fi
    printf "Generating $name.md\n"
    
cat <<EOF > output/connections/$name.md
---
title: "${name}"
---
    
content
EOF

done < <(jq -r ".network_connections[] | [.ptr_domain, .ip_address] | @csv" manifests/* 2>/dev/null | sort -u)
