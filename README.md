# zfs-quota
This is a very rudimentary quota checking system for a ZFS based NFS Server as the default quota method doesnt work in linux.

Expect this to break.

## Versions and Differences
Version 1 is available in the branch v1, the main branch is now a modified version marked as v2.
Version 2 is not backwards compatible with v1 which is why the version numbers changed. Version 2 utilises UIDs and not Usernames.

## Sample Usage:

This is aimed at network envrionments where end users require some form of quota output.
We assume that the root of the ZFS mount point is the mount point for the users data, this may not be your use case, please uncomment ands set the variable QLOC in the server script.

Put the server script into cron:
```bash
echo "*/2 * * * * root ZFS-Quota-Server.sh homes/home >/dev/null 2>&1" >> /etc/cron.d/zfs-quota
```

Touch the quota.zfs and set permissions for first run, change homes/home for your ZFS vol.
```bash
touch $(zfs get mountpoint homes/home -H | awk '{print $3}')/quota.zfs
chmod 744 $(zfs get mountpoint homes/home -H | awk '{print $3}')/quota.zfs
```

the quota.zfs output should look similar to this (showing UIDs and not Usernames):
```
1001::1307875224::161061273600::1%
1::56580187648::64424509440::88%
```

Add the list of ZFS Servers to the array in the client script and the correct mountpoint, you could then alias quota with this script is required.

The sample output should look like this
```

 Quota Report for aboutcher
 Mount				Used		Total		Last Checked
 /mnt/home			1.3G (1%)	150G		Wed 28 Jun 2017 16:21:44 BST

```
and for mulutiple servers similar to below
```

 Quota Report for aboutcher
 Mount				Used		Total		Last Checked
 /mnt/home			1.3G (1%)	150G		Tue 13 Jul 2021 16:00:00 BST
 /mnt/storage			23T (10%)	230T		Tue 13 Jul 2021 16:00:00 BST

```


## Known Issues
Version 2 brings in the problem that a UID might collide and match with a bytesize output from ZFS. This has hopefully been mitigated against.

## About

This reposistory is based on work mentioned on my [blog](https://aboutcher.co.uk/2017/06/linux-zfs-quotas-hacked-solution/) and is split out from work contained in [aboutcher/GridScripts](https://github.com/adamboutcher/Grid-Scripts) which is work for the [IPPP](https://www.ippp.dur.ac.uk) at [Durham University](https://www.dur.ac.uk).

All code contained is Copyright myself (Adam Boutcher) and/or the IPPP unless otherwise stated in the header of the file. They are provided free for use but include no liability or warrenty; more or less the GPLv3.

More from me at my [website](http://www.aboutcher.co.uk).
