#!/bin/bash
TEMP=$(mktemp)
CONNECTION=$(mktemp)
json="$1"

# Setup names
package=$(jq -r .packageName "$1")
name=$(jq -r .appName "$1")
category=$(jq -r .category "$1")

IFS=$'\n' read -d '' -r -a trackers < <(jq -r ".trackers[]" "$1" | tr ' ' '-')
jq -r ".trackers[]" "$1" 2>/dev/null >/dev/null
if [[ "$?" -eq "5" ]]; then
    no_trackers=1
    echo "No trackers"
fi

IFS=$'\n' read -d '' -r -a permissions < <(jq -r ".permissions[]" "$1" | sed -e "/com.sec.spp.permission.TOKEN/d" | sort -u )
jq -r ".permissions[]" "$1" 2>/dev/null >/dev/null
if [[ "$?" -eq "5" ]]; then
    no_permissions=1
    echo "No permissions"
fi

IFS=$'\n' read -d '' -r -a connections < <( jq -r ".network_connections[] | [.ptr_domain, .ip_address, .loc_lat, .loc_long, .loc_city, \
            .loc_country, .loc_continent ] | @csv" "$1" 2>/dev/null \
            | sed -e "s/\",\"/%\/%/" -e "s/\"//g" -e "s/ /%/g" -e "s/\*\.//g")
jq -r ".network_connections[]" "$1" 2>/dev/null >/dev/null
if [[ "$?" -eq "5" ]]; then
    no_connections=1
    echo "No connections"
fi
punknown=0
pnormal=0
pdangerous=0
pinstant=0
psignature=0
pappop=0
pdevelopment=0
ppre23=0
ppreinstalled=0
for permission in ${permissions[@]}; do
    ARGS=".[] | select(.name | test(\"^$permission$\")) | .protectionLevel"
    unknown=0
    for level in $(jq -r "$ARGS" permissionsDatabase.json | tr ' ' '\n'); do
       value="p$level"
       if [ "$value" == "pnormal" ]; then pnormal=$(( $pnormal + 1 )); unknown=1; fi
       if [ "$value" == "pdangerous" ]; then pdangerous=$(( $pdangerous + 1 )); unknown=1; fi
       if [ "$value" == "pinstant" ]; then pinstant=$(( $pinstant + 1 )); unknown=1; fi
       if [ "$value" == "psignature" ]; then psignature=$(( $psignature + 1 )); unknown=1; fi
       if [ "$value" == "pappop" ]; then pappop=$(( $pappop + 1 )); unknown=1; fi
       if [ "$value" == "pdevelopment" ]; then pdevelopment=$(( $pdevelopment + 1 )); unknown=1; fi
       if [ "$value" == "ppre23" ]; then ppre23=$(( $ppre23 + 1 )); unknown=1; fi
       if [ "$value" == "ppreinstalled" ]; then ppreinstalled=$(( $ppreinstalled + 1 )); unknown=1; fi
    done
    if [ "$unknown" == "0" ]; then punknown=$(( $punknown + 1 )); fi
done

printf "generating $package md\n"

cat <<EOF > output/apps/$package.md
---
layout: none
title: "${name:-$package}"
icon: "/assets/icons/$package.png"
link: "/apps/$package"
categories: "${category:-unlabeled}"
unknownCount: "$punknown"
normalCount: "$pnormal"
dangerousCount: "$pdangerous"
instantCount: "$pinstant"
signatureCount: "$psignature"
appopCount: "$pappop"
developmentCount: "$pdevelopment"
pre23Count: "$ppre23"
preinstalledCount: "$ppreinstalled"
EOF

if [[ "${no_trackers}" -ne "1" ]]; then
cat <<EOF >> output/apps/$package.md
trackers:
EOF
for tracker in ${trackers[*]}; do
    printf "  - $tracker \n" >> output/apps/$package.md
done 
else
    printf "trackers: \"none-found\" \n" >> output/apps/$package.md
fi

printf "trackerCount: ${#trackers[@]} \n" >> output/apps/$package.md

if [[ "${no_permissions}" -ne "1" ]]; then
cat <<EOF >> output/apps/$package.md
permissions:
EOF
for permission in ${permissions[*]}; do
    printf "  - $permission \n" >> output/apps/$package.md
done
else
    printf "permissions: \"none-found\" \n" >> output/apps/$package.md
fi

printf "permissionCount: ${#permissions[@]} \n" >> output/apps/$package.md

if [[ "${no_connections}" -ne "1" ]]; then
cat <<EOF >> output/apps/$package.md
connections:
EOF
for connection in ${connections[*]}; do
    connectionname=$(echo "${connection}" | cut -d"," -f1 | sed "s/%//g" )
    if egrep -q "^N/A" <<< "$connectionname"; then
        echo "  - $(printf "$connectionname" | cut -d"/" -f3 )" >> output/apps/$package.md
    else
        echo "  - $connectionname" | cut -d"/" -f1 | sed "s/\.$//g" >> output/apps/$package.md
    fi
done
else
    printf "connections: \"none found\" \n" >> output/apps/$package.md
fi

printf "connectionCount: ${#connections[@]} \n" >> output/apps/$package.md

cat <<EOF >> output/apps/$package.md

---

EOF

if [[ "${no_permissions}" -ne "1" ]]; then
printf "## Permissions \n" >> output/apps/$package.md
for permission in ${permissions[*]}; do
    printf "{{< permission \"$permission\" >}}\n" >> output/apps/$package.md
done
fi

if [[ "${no_trackers}" -ne "1" ]]; then
printf "## Trackers \n" >> output/apps/$package.md
for tracker in ${trackers[*]}; do
    printf "{{< tracker \"$tracker\" >}}\n" >> output/apps/$package.md
done 
fi

if [[ "${no_connections}" -ne "1" ]]; then
printf "## Map of past connections \n" >> output/apps/$package.md
printf "{{< map \n" >> output/apps/$package.md
for connection in ${connections[*]}; do
    printf "\"${connection//%/ }\"\n" >> output/apps/$package.md
done
printf ">}} \n" >> output/apps/$package.md
fi

rm $TEMP $CONNECTION
