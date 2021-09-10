#!/bin/bash
# ZFS Quota Client v2.5
# 2021 - Adam Boutcher
# IPPP, Durham University

# User Quota
servers[0]="/mnt/home"
servers[2]="/mnt/storage"

# Group Quota
grpsrvs[0]="/mnt/groups"

################################################################################
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
check_bin date
check_bin getent

printf "\n Storage Quota v2.5 BETA - This *might* sometimes break."
printf "\n Group reports are entire group usage not individual.\n"
printf "\n Quota Report for $QUSER\n"
printf ' %-35s %-15s %-10s %-20s\n' "Mount Point" "Used" "Total" "Last Checked";

# User Checks
QUID=$(id -u $QUSER 2>/dev/null)
for i in "${servers[@]}"; do
  zquota=$(cat $i/quota.zfs 2>/dev/null | grep $QUID 2>/dev/null);
  if [[ ! -z "$zquota" ]]; then
    for ii in $zquota; do
      zuid=$(echo $ii | awk -F'::' '{print $1}')
      if  [[ $zuid == $QUID ]]; then
        zused=$(echo $ii | awk -F'::' '{print $2}' | numfmt --to=iec);
        if [[ $zused == "nan" ]]; then
          zused=0;
        fi
        ztotal=$(echo $ii | awk -F'::' '{print $3}');
        if [[ $ztotal -ne "none" ]]; then
          ztotal=$(echo $ztotal | numfmt --to=iec);
        fi
        zperc=$(echo $ii | awk -F'::' '{print $4}');
      fi
    done
    zage=$(date +"%c" -d @$(stat -c %Z $i/quota.zfs))
    printf ' %-35s %-15s %-10s %-20s\n' "$i" "$zused ($zperc)" "$ztotal" "$zage";
  fi
done;

# Group Checks
for g in $(id -G $QUSER 2>/dev/null); do
  for i in "${grpsrvs[@]}"; do
    zquota=$(cat $i/quota.zfs 2>/dev/null | grep $g 2>/dev/null);
    if [[ ! -z "$zquota" ]]; then
      for ii in $zquota; do
        zgid=$(echo $ii | awk -F'::' '{print $1}')
        zgnm=$(getent group $g | awk -F':' '{print $1}')
        if  [[ $zgid == $g ]]; then
          zused=$(echo $ii | awk -F'::' '{print $2}' | numfmt --to=iec);
          if [[ $zused == "nan" ]]; then
            zused=0;
          fi
          ztotal=$(echo $ii | awk -F'::' '{print $3}');
          if [[ $ztotal -ne "none" ]]; then
            ztotal=$(echo $ztotal | numfmt --to=iec);
          fi
          zperc=$(echo $ii | awk -F'::' '{print $4}');
        fi
      done
      zage=$(date +"%c" -d @$(stat -c %Z $i/quota.zfs))
      printf ' %-35s %-15s %-10s %-20s\n' "$i ($zgnm)" "$zused ($zperc)" "$ztotal" "$zage";
    fi
  done;
done;


printf "\n"
exit 0;
