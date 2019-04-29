#!/bin/bash
while read tracker; do
    printf "Generating $tracker/_index.md \n"
    mkdir "output/trackers/$tracker" 2>/dev/null
cat <<EOF > "output/trackers/$tracker/_index.md"
---
title: "${tracker//-/ }"
layout: "trackers"
---
    
EOF
done < <(jq -r .trackers[] manifests/* | sort -u | sed -e "s/ /-/g")
