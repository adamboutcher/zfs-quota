#!/bin/bash
# ZFS Quota Client
# 2021 - Adam Boutcher
# IPPP, Durham University

servers[0]="/mt/home"
servers[1]="/mt/storage"

if [ -z "$1" ]; then
	QUSER=$USER
else
	QUSER=$1
fi

function check_bin() {
  which $1 1>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "$1 cannot be found. Please install it or add it to the path. Exiting."
    exit 1
  fi
}

check_bin which
check_bin printf
check_bin cat
check_bin grep
check_bin echo
check_bin awk
check_bin stat
check_bin numfmt
check_bin stat

printf "\n Storage Quota v2 BETA - This *might* sometimes break.\n\n"
printf "\n Quota Report for $QUSER\n"
printf ' %-30s %-15s %-15s %-25s\n' "Mount Point" "Used" "Total" "Last Checked";
QUID=$(id -u $QUSER)
for i in "${servers[@]}"; do
	zquota=$(cat $i/quota.zfs 2>/dev/null | grep -m 1 -w $QUID);
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
