#!/bin/bash
IFS=$'\r\n' GLOBIGNORE='*' command eval 'folders=$(ls -1 -p | grep "/")'

for folder in ${folders[*]}; do
    rm ${folder/\///}.csv 2>/dev/null
    for i in $folder*.bson; do
        bsondump $i 2>/dev/null \
            | jq -r "[ .flow_headers.PACKAGE , .flow_headers.DSTIP] | @csv" \
              >> ${folder/\///}.csv 2>/dev/null
    done
done

