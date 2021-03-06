#!/bin/bash
## Maintainer chris.d@linuxpersonal.com

source <(curl -s https://raw.githubusercontent.com/linuxpersonal/scripts/master/phpselector/phpextensions)

function table () {

printf "\

PHP Selector
---------------------------------------------

Please choose required PHP version below

1. PHP Version 5.3 (Stock)
2. PHP Version 5.4
3. PHP Version 5.5 
4. PHP Version 5.6 
5. PHP Version 7.0 
6. PHP Version 7.1 
7. PHP Version 7.2
8. Exit

---------------------------------------------

"
}

function remi_repo () {

ping -c1 google.com &>/dev/null

if [ $? = 1 ]; then
    print "\nPlease check internet status\n"
    exit 1
fi

yum install \
    epel-release \
    yum-utils -y
yum upgrade rpm -y

rpm -qa | grep remi-release 

if [ $? = 1 ]; then

    yum -y install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    
    if [ $? = 1 ]; then
        printf "\nUnable to install remi-release\n"
        exit 1
    fi
fi

}

function php_install () {

printf "\nInstaiing PHP $1\n"

yum-config-manager --disable remi-php* 1>/dev/null

remi_repo
yum remove php-common -y

if [ $1 = "5.3" ]; then
    yum install $2 -y
else
    yum-config-manager --enable remi-$2
    yum install $3 -y
fi

}

clear

printf "\nWelcome to the PHP Version Change Script\n"
printf "\nTo enable/disable PHP extensions please edit /opt/phpselector/phpextensions\n\n"
table

read -p "[CAUTION] Please proceed with caution when making PHP version changes [Press enter to continue]"
echo ""
read -p "Please enter number from table: " userinput

case "$userinput" in

1) php_install "5.3" "$php53"
   ;;
2) php_install "5.4" "php54" "$php54"
   ;;
3) php_install "5.5" "php55" "$php55"
   ;;
4) php_install "5.6" "php56" "$php56"
   ;;
5) php_install "7.0" "php70" "$php70"
   ;;
6) php_install "7.1" "php71" "$php71"
   ;;
7) php_install "7.2" "php72" "$php72"
   ;;
*) printf "\nTerminating Script\n"
   exit 0
   ;;
esac
