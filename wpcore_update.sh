#!/bin/bash

## Welcome to the wordpress update script
## This script will update the wordpress core files
## Files such as wp-content/ and wp-config.php are untouched
## Please ensure you create a backup before executing

function diskcheck () {

    wordpress_dir=$1

    total=$(df -P $wordpress_dir | awk 'NR==2 {print $4}')
    wpdir_size=$(du -s $wordpress_dir | cut -f1)

    if [ $wpdir_size -gt $total ]; then
        printf "\nError: Further disk space recommended\n"
        exit 1
    fi

}

function upgrade () {
    
    wordpress_dir=$1

    rpm -qa | grep unzip

    if [ $? = 1 ]; then
        yum install unzip -y
    fi

    read -p "[CAUTION]\
    Upgrade Commencing, ENSURE you have created a backup\
    [Enter to continue]"

    echo ""

    wp_core="https://wordpress.org/latest.zip"

    wget -O /tmp/wp_core.zip $wp_core
    unzip -d /tmp/ /tmp/wp_core.zip -x "wordpress/wp-content*"

    cp -rf /tmp/wordpress/* $wordpress_dir

    if [ $? = 0 ]; then
        printf "\nManual Wordpress Upgrade Success\n\n"
        rm -rf /tmp/wordpress /tmp/wp_core.zip
    else
        printf "\nWordpress Upgrade Failed\n"
        exit 1
    fi

}

function create_backup () {
    
    wordpress_dir=$1

    diskcheck "$wordpress_dir"
    tdate=$(date '+%Y%m%d')
    
    printf\
        "\n\nDo you wish to create a backup?
        \nEnter y or yes to continue: "

    read choice

    if [ ! -d $wordpress_dir ]; then
        echo "Unable to locate directory"
        exit 1
    fi

    if [[ $choice =~ ^[Yy]$ ]]; then
        
        echo ""
        read -p "Insert only directory of backup [e.g /home]: " backup

        if [ ! -d $backup ]; then
            printf "\nUnable to locate directory\n"
            exit 1
        fi

        tar -czf "$backup/wp-$tdate.gz" $wordpress_dir
        
        if [ $? != 0 ]; then
            printf "\nBackup has failed"
            exit 1
        fi

        printf "\nBackup has been completed\n\n"
    else
        printf "\nNot Creating Backup\n\n"
    fi

}

wordpress_dir=$1

if [ -z $wordpress_dir ]; then
    printf "\nUsage: $0 [Insert location of wordpress install]"
    exit 1
fi

printf "\nWelcome to the Wordpress Upgrade Script\n\
---------------------------------------------------"
create_backup "$wordpress_dir"
upgrade "$wordpress_dir"
