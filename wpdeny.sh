#!/bin/bash

xmlvalue=$(cat /var/log/nginx/access.log | grep xml | sort | awk '{print $1}' | uniq -c | sort -rn | awk NR==1 | awk '{print $1}')
IP=$(cat /var/log/nginx/access.log | grep xml | sort | awk '{print $1}' | uniq -c | sort -rn | awk NR==1 | awk '{print $2}')
postvalue=$(cat /var/log/nginx/access.log | grep POST | sort | awk '{print $1}' | uniq -c | sort -rn | awk NR==1 | awk '{print $1}')
IP2=$(cat /var/log/nginx/access.log | grep POST | sort | awk '{print $1}' | uniq -c | sort -rn | awk NR==1 | awk '{print $2}')
d=$(date)

if [ -z $xmlvalue ] && [ -z $postvalue ]; then 
   exit 0
fi

if [ ! -z $xmlvalue ]; then
    if [ $xmlvalue -gt 500 ]; then
        /usr/sbin/csf -g $IP | grep "csf.deny: $IP # Manually denied" &>/dev/null
        if [ $? != 0 ]; then
            /usr/sbin/csf -d $IP
            grep "$d $IP for xml has been added to csf.deny" >> /dev/null
	    if [ $? != 0 ]; then
	    echo "$d $IP for xml has been added to csf.deny" >> /root/wpdeny.log
	    fi	
        else
	:
        fi
    fi
else
    :
fi

if [ ! -z $postvalue ]; then
    if [ $postvalue -gt 500 ]; then
        /usr/sbin/csf -g $IP2 | grep "csf.deny: $IP2 # Manually denied" &>/dev/null
        if [ $? != 0 ]; then
            /usr/sbin/csf -d $IP2
            grep "$d $IP2 for POST has been added to csf.deny" >> /dev/null
	    if [ $? !=0 ]; then
            echo "$d $IP2 for POST has been added to csf.deny" >> /root/wpdeny.log
            fi
	else
	:
        fi
    fi
else 
    :
fi
