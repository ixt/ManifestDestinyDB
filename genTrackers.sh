#!/bin/bash
while read tracker; do
    printf "Generating $tracker.md"
cat <<EOF > output/trackers/$tracker.md
---
title: "${tracker//-/ }"
layout: "trackers"
---
    
content
EOF

done < <(jq -r .trackers[] manifests/* | sort -u | sed -e "s/ /-/g")
