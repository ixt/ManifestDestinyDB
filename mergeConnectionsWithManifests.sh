#!/bin/bash
TEMP=$(mktemp)
TEMPM=$(mktemp)
for file in $(ls -1 ./manifests/*.json | cut -d"/" -f 3- | sed -e "s/\.json//g" ); do
    changes=0
	cat <<EOF > $TEMP
	{ "network_connections" : [
EOF
	for packet in $(ls -1 packets/handshakes/$file*); do
        changes=1
		cat $packet >> $TEMP
		echo "," >> $TEMP
	done
	sed -i '$s/,$//' $TEMP
	cat <<EOF >> $TEMP
	] }
EOF

jq -s add ./manifests/$file.json $TEMP \
    > $TEMPM
if [[ "$changes" -eq "1" ]]; then
    cat $TEMPM
    echo $file
    cp $TEMPM ~/manifests/$file.json
fi

done

rm $TEMP $TEMPM
