#!/bin/bash
# ZFS Quota Server - Version 2
# 2021 - Adam Boutcher
# IPPP, Durham University
# This pulls the quota info from ZFS and outputs to a file to parse remotely

ZFS="/usr/sbin/zfs"
#QLOC=/mnt/blah

# Function to check that a binary exists
function check_bin() {
  which $1 1>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "$1 cannot be found. Please install it or add it to the path. Exiting."
    exit 1
  fi
}

check_bin which
check_bin $ZFS
check_bin echo
check_bin awk
check_bin sed
check_bin grep

if [[ -z "$1" ]]; then
  echo "Please include a quota pool i.e. homes/home";
  exit 1;
fi

# Check the zfs pool/vdev exists
$ZFS list 2>&1 | sed -n '1!p' | awk '{print $1}' | grep $1 >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "$1 cannot be found. Please check your ZFS setup."
  exit 1
fi

# Modifying the IFS
SAVEIFS=$IFS
IFS="
"

if [ -z $QLOC ]; then
  QLOC=$($ZFS get mountpoint -H $1 2>/dev/null | awk '{print $3}')
else
  QLOC=$QLOC
fi

zcmd=$($ZFS userspace -p -n $1 2>/dev/null | sed -n '1!p');
if [ -f $QLOC/quota.zfs ]; then
  > $QLOC/quota.zfs
  for zquota in `echo "$zcmd"`; do
    zuser=$(echo $zquota| awk '{print $3}');
    zused=$(echo $zquota| awk '{print $4}');
    zquot=$(echo $zquota| awk '{print $5}');
    if [[ zquot -ne "none" ]]; then
      zperc=$(echo $zquota| awk '{printf "%.0f\n",  ($4/$5) * 100}');
    else
      zpec=0;
    fi
    echo -e "$zuser::$zused::$zquot::$zperc%" >> $QLOC/quota.zfs
  done;
fi
# Reset IFS
IFS=$SAVEIFS
exit 0;
