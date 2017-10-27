#!/bin/bash                          

sslname=$1                           

yum install -y epel-release          
yum update                           
yum install -y certbot nginx python2-certbot-nginx                         
systemctl restart nginx              

if [ $# != 1 ];then                  
    echo -e "\nPlease insert domain name e.g. $0 example.com\n"            
    exit                             
fi                                   

echo -e "\nPlease ensure this domain exists within your vhosts file e.g. /etc/nginx/sites-enabled/example.com.conf\n"                                 

ls -R /etc/nginx/ | grep ${sslname}.conf > /dev/null                       

if [ $? != 0 ]; then                 
    echo "Error: Unable to locate configuration file for $sslname"         
    exit                             
fi                                   

grep -R www.${sslname} /etc/nginx >/dev/null                               

if [ $? = 0 ]; then                  
    certbox --nginx -d $sslname -d www.${sslname}                          
    if [ $? = 1 ]; then              
        certbot --nginx -d $sslname  
    fi                               
else                                 
certbot --nginx -d $sslname          
fi                                   

systemctl reload nginx               

crontab -l | grep "/usr/bin/certbot renew --quiet" > /dev/null             

if [ $? != 0 ]; then                 
    (crontab -l 2>/dev/null; echo "15 3 * * * /usr/bin/certbot renew --quiet") | crontab -                                                            
fi
