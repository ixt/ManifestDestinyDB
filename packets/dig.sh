#!/bin/bash
# Go through a csv of package names and IP's resolve each ip to a PTR DNS record and look up the ip in GeoLiteCity db
GEOLITE="/usr/share/GeoIP/GeoLite2-City_20190319/GeoLite2-City.mmdb"
# IP="31.13.81.13"
TEMP=$(mktemp)
while read entry; do
    IFS=, read -a line <<< "$entry"
    PACKAGE=$(echo ${line[0]} | xargs echo )
    IP=$(echo ${line[1]} | xargs echo)
    PTRDOMAIN=$(dig -x $IP \
        +noquestion +norrcomments +nottlid +noadditional \
        +nocl +nocmd +nostats +nocrypto \
        | grep -A1 "ANSWER SECTION" \
        | tail -1 \
        | sed -e "s/^.*PTR[[:space:]]*//g" )

    CITY=$(mmdblookup -f $GEOLITE --ip $IP city names en 2>/dev/null | cut -d'"' -f2 | xargs echo) 
    COUNTRY=$(mmdblookup -f $GEOLITE --ip $IP country names en 2>/dev/null | cut -d'"' -f2 | xargs echo)
    CONTINENT=$(mmdblookup -f $GEOLITE --ip $IP continent names en | cut -d'"' -f2 | xargs echo )
    LONG=$(mmdblookup -f $GEOLITE --ip $IP location longitude 2>/dev/null | xargs echo | cut -d" " -f1)
    LAT=$(mmdblookup -f $GEOLITE --ip $IP location latitude 2>/dev/null | xargs echo | cut -d" " -f1)

cat <<EOF> $TEMP
{ 
    "package": "$PACKAGE",
    "ptr_domain": "${PTRDOMAIN:-"N/A"}",
    "ip_address": "$IP",
    "loc_city": "${CITY:-"N/A"}",
    "loc_country": "${COUNTRY:-"N/A"}", 
    "loc_continent": "${CONTINENT:-"N/A"}",
    "loc_long": "${LONG:-"N/A"}", 
    "loc_lat": "${LAT:-"N/A"}"
}
EOF
cp $TEMP handshakes/$PACKAGE.$IP.json
echo $PACKAGE,$IP,$PTRDOMAIN
done < handshakes.csv
rm $TEMP
