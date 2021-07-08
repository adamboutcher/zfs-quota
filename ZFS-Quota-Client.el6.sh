#!/bin/bash
# ZFS Quota Client

servers[0]="/mt/home"

if [ -z "$1" ]; then
	QUSER=$USER
else
	QUSER=$1
fi

printf "\n Quota Report for $QUSER\n"
printf ' %-30s %-15s %-15s %-25s\n' "Mount Point" "Used" "Total" "Last Checked";

for i in "${servers[@]}"; do
	zquota=$(cat $i/quota.zfs 2>/dev/null | grep $QUSER);
	if [[ ! -z "$zquota" ]]; then
		zused=$(echo $zquota | awk -F'::' '{print $2}' | numfmt --to=iec);
		ztotal=$(echo $zquota | awk -F'::' '{print $3}');
		if [[ $ztotal -ne "none" ]]; then 
			ztotal=$(echo $ztotal | numfmt --to=iec);
		fi
		zperc=$(echo $zquota | awk -F'::' '{print $4}');
		zage=$(date +"%c" -d @$(stat -c %Z $i/quota.zfs))
		printf ' %-30s %-15s %-15s %-25s\n' "$i" "$zused ($zperc)" "$ztotal" "$zage";
	fi
done;
printf "\n"
exit 0;