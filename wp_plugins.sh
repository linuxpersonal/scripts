#!/bin/bash

## This is a script that manually updates all plugins within your wordpress installation
## To use script -> ./wp_plugins.sh [location of wordpress install e.g. /var/www/html/wordpress]
## Example -> ./wp_plugins.sh /var/www/html/wordpress

function line () {
echo -e \
"-----------------------------------------------\n"
}

function install_checks () {
  
  for i in "unzip" "lynx" "curl"; do
  
    rpm-qa | grep $i
    if [ $? = 1 ]; then
      yum install $i
    fi
 
  done
}

function plugin_url () {

  temp_dir=$(mktemp -d) 

  curl $1 -o $temp_dir/url.html
  dl_link=$(lynx --listonly -dump $temp_dir/url.html \
  | grep downloads.wordpress | awk '{print $2}')

  rm -rf $temp_dir
  echo $dl_link

}

function create_backup () {
    
  plugins_dir=$1
  tdate=$(date '+%Y%m%d')
  
  printf \
    "Do you wish to create a backup?
    \nEnter [Yy] or [Yy]es to continue: "

  read choice

  if [[ $choice =~ ^[Yy]$ ]]; then
      
    echo ""
    read -p "Insert only directory of backup [e.g /home]: " backup

    if [ ! -d $backup ]; then
        printf "\nUnable to locate directory\n"
        exit 1
    fi

    tar -czf "$backup/wpplugins-$tdate.gz" $plugins_dir
    
    printf "\nBackup has been completed\n\n"
  else
    printf "\nNot Creating Backup\n\n"
  
  fi

}

if [ ! -d $1 ]; then
  printf "\nUsage: $0 [Location of wordpress install e.g. /var/www/html/public_html]"
  exit 1
fi

printf "\nWelcome to the Wordpress Plugins Update Script\n"
line

plugin_root="$1/wp-content/plugins"
plugin_list=$(ls $plugin_root | grep -v ".php")
temp_dir=$(mktemp -d)

printf "Running Server Checks\n"
install_checks &>/dev/null
echo ""
create_backup $plugin_root

printf "Updating plugins now, this may take some time\n"
line
printf "List of Plugins to be updated:\n\n"
for i in $plugin_list; do echo $i; done

printf "\n[CAUTION] Please Ensure you have created a backup of your wordpress install"
printf "\n[Press Enter to Continue]\n"
read

printf "Download Plugins:\n"
line

declare -a ARRAY=()

for i in $plugin_list; do

  plugin_link=$(plugin_url https://wordpress.org/plugins/$i/ 2>/dev/null)
  ARRAY=(${ARRAY[*]} $plugin_link)
  
  if [ -z $plugin_link ]; then
    echo "$i" >> "$temp_dir/error.txt"
  fi

done

for i in ${ARRAY[*]}; do
  
  echo "Downloading $i" 
  wget -P $temp_dir $i &>/dev/null

done

printf "\nPlugin Update Results:\n"
line

for i in $(ls $temp_dir); do
  
  if [ $i != "error.txt" ]; then
  
    unzipped=$(echo $i | cut -f1 -d.)
    unzip -d $temp_dir $temp_dir/$i &>/dev/null
    
    rm -rf $plugin_root/$unzipped
    cp -rf $temp_dir/$unzipped $plugin_root
    printf "Update of plugin $unzipped completed\n"
  
  fi

done

if [ -f "$temp_dir/error.txt" ]; then
  printf "\nPlugins below were not updated/unsuccessful:\n\n"
  cat "$temp_dir/error.txt"
fi

echo ""
rm -rf $temp_dir
