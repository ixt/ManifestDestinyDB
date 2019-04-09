#!/bin/bash
TEMP=$(mktemp)
TEMPM=$(mktemp)
for file in $(ls -1 ~/manifests/*.json | cut -d"/" -f 2- | sed -e "s/\.json//g" ); do
    IFS='/' read -a manifest <<< "$file"
    changes=0
	cat <<EOF > $TEMP
	{ "network_connections" : [
EOF
	for packet in $(ls -1 packets/handshakes/${manifest[3]}*); do
        changes=1
		cat $packet >> $TEMP
		echo "," >> $TEMP
	done
	sed -i '$s/,$//' $TEMP
	cat <<EOF >> $TEMP
	] }
EOF

jq -s add ~/manifests/${manifest[3]}.json $TEMP \
    > $TEMPM
if [[ "$changes" -eq "1" ]]; then
    cat $TEMPM
    echo ${manifest[3]}
    cp $TEMPM ~/manifests/${manifest[3]}.json
fi


done

rm $TEMP $TEMPM
