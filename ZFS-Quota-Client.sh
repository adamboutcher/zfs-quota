#!/bin/bash
# ZFS Quota Client v2
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
check_bin id

printf "\n Storage Quota v2 BETA - This *might* sometimes break.\n\n"
printf "\n Quota Report for $QUSER\n"
printf ' %-30s %-15s %-15s %-25s\n' "Mount Point" "Used" "Total" "Last Checked";
QUID=$(id -u $QUSER)
for i in "${servers[@]}"; do
  zquota=$(cat $i/quota.zfs 2>/dev/null | grep $QUID);
  if [[ ! -z "$zquota" ]]; then
    for ii in $zquota; do 
      zuid=$(echo $ii | awk -F'::' '{print $1}')
      if  [[ $zuid == $QUID ]]; then
        zused=$(echo $ii | awk -F'::' '{print $2}' | numfmt --to=iec);
        ztotal=$(echo $ii | awk -F'::' '{print $3}');
        if [[ $ztotal -ne "none" ]]; then
          ztotal=$(echo $ztotal | numfmt --to=iec);
        fi
        zperc=$(echo $ii | awk -F'::' '{print $4}');
      fi
    done 
    zage=$(date +"%c" -d @$(stat -c %Z $i/quota.zfs))
    printf ' %-30s %-15s %-15s %-25s\n' "$i" "$zused ($zperc)" "$ztotal" "$zage";
  fi
done;
printf "\n"
exit 0;
