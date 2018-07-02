#!/bin/bash

hostname=$1
date=$(date +%d)

if [ ! -d "/backups/vms/$hostname" ]; then
  mkdir "/backups/vms/$hostname"
fi

number=$(date +%d -d "1 day ago")

syncfile="/backups/vms/$hostname/$hostname-$number.backup"

rsync -r -a -e "ssh -o StrictHostKeyChecking=no" --delete --link-dest=$syncfile --exclude={dev,/lib/init/rw,/mnt,/proc,/run,/selinux,/sys,/tmp,/var/cache,/var/run,/var/spool,/Multimedia} root@$hostname:/ /backups/vms/$hostname/$hostname-$date.backup

