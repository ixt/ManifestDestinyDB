#!/bin/bash
mkdir output/categories
while read category; do
    url=$( echo "$category" | tr '[:upper:]' '[:lower:]')
    mkdir output/categories/$url
    cat <<EOF > output/categories/$url/_index.md
---
title: "$category"
---

EOF
done < otherData/PlayStoreCategories.list
