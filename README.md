# zfs-quota
This is a very rudimentary quota checking system for a ZFS based NFS Server as the default quota method doesn't work in Linux.

Expect this to break.

![License](https://img.shields.io/github/license/adamboutcher/zfs-quota?color=green&label=License&logoColor=white) ![GitHub last v1 commit](https://img.shields.io/github/last-commit/adamboutcher/zfs-quota/v1?label=Last%20v1%20Commit&logo=github&logoColor=white) ![GitHub last v2 commit](https://img.shields.io/github/last-commit/adamboutcher/zfs-quota/main?label=Last%20v2%20Commit&logo=github&logoColor=white)

## Versions and Differences
- Version 1 is available in the branch v1, the main branch is now a modified version marked as v2.
- Version 2 is not backwards compatible with v1 which is why the version numbers changed. Version 2 utilises UIDs and not Usernames.
- Version 3 is a unified script for groups and users which is partially backwards compabile with v2.

## Server
### Sample Usage:
This is aimed at network environments where end users require some form of quota output.
We assume that the root of the ZFS mount point is the NFS mount point for the users data, this may not be your use case, if it isn't then add the NFS mount location as the second parameter similar to the second example below.

Put the server script into cron, change homes/home for your ZFS vol.:
```bash
echo "*/2 * * * * root ZFS-Quota-Server.sh homes/home >/dev/null 2>&1" >> /etc/cron.d/zfs-quota
```
or if you need to override the quota output, change for your zvol and directory.
```bash
echo "*/2 * * * * root ZFS-Quota-Server.sh MyPool/Users user /export/Users/Docs >/dev/null 2>&1" >> /etc/cron.d/zfs-quota
```

Touch the quota.zfs and set permissions for first run, change homes/home for your ZFS vol.
```bash
touch $(zfs get mountpoint homes/home -H | awk '{print $3}')/quota.zfs
chmod 744 $(zfs get mountpoint homes/home -H | awk '{print $3}')/quota.zfs
```
or for our example using an override
```bash
touch /export/Users/Docs/quota.zfs
chmod 744 /export/Users/Docs/quota.zfs
```

the quota.zfs output should look similar to this (showing UIDs and not Usernames, unlike v1):
```
1001::1307875224::161061273600::1%
1::56580187648::64424509440::88%
```
### Experimental Group Support:
This is a very simple change to support ZFS group quotas. We highly suggest not running user and group quotas on the same zvol.
```bash
echo "*/2 * * * * root ZFS-Quota-Server.sh shared/groups group >/dev/null 2>&1" >> /etc/cron.d/zfs-quota
```

## Client
### Sample Usage:
Add the list of ZFS Servers to the array in the client script and the correct mount point, you could then alias quota with this script is required.

The sample output should look like this
```

 Quota Report for aboutcher
 Mount          Used       Total    Last Checked
 /mnt/home      1.3G (1%)  150G     Wed 28 Jun 2017 16:21:44 BST

```
and for multiple servers similar to below94980eb
```

 Quota Report for aboutcher
 Mount          Used       Total    Last Checked
 /mnt/home      1.3G (1%)  150G     Tue 13 Jul 2021 16:00:00 BST
 /mnt/storage   23T (10%)  230T     Tue 13 Jul 2021 16:00:00 BST

```
### Experimental Group Support:
Version 2.5 of the client supports the group quota system. Group reports are for the entire group and not the individual.
You will have to add the group server mount points into the array grpsrvs.

The sample output should look like this
```

 Quota Report for aboutcher
 Mount Point             Used       Total    Last Checked
 /mnt/home               1.3G (1%)  150G     Tue 13 Jul 2021 16:00:00 BST
 /mnt/storage            23T (10%)  230T     Tue 13 Jul 2021 16:00:00 BST
 /mnt/groups (admin)     23T (10%)  230T     Tue 13 Jul 2021 16:00:00 BST

```


## Known Issues
**Fixed** - Version 2 brought in the problem that a UID might collide and match with a bytesize output from ZFS. This has hopefully been mitigated against (see [commit 94980eb](https://github.com/adamboutcher/zfs-quota/commit/94980ebd455acc0d99e384bb116bd67def1ea45b)).

## About

This reposistory is based on work mentioned on my [blog](https://aboutcher.co.uk/2017/06/linux-zfs-quotas-hacked-solution/) and is split out from work contained in [adamboutcher/GridScripts](https://github.com/adamboutcher/Grid-Scripts) which is work for the [IPPP](https://www.ippp.dur.ac.uk) at [Durham University](https://www.dur.ac.uk).

All code contained is Copyright myself (Adam Boutcher) and/or the IPPP unless otherwise stated in the header of the file. They are provided free for use but include no liability or warranty; more or less the GPLv3.

More from me at my [website](http://www.aboutcher.co.uk).
