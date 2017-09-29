#!/usr/bin/python2.7
import subprocess as s
import platform
import os
import sys
import urllib
import tarfile
import MySQLdb as sql


class wp():

    def __init__(self, website):

        self.website = website

    def check(self):

        print('\nThis is a script to install Apache and Wordpress\n')

        if len(self.website) < 3 or '.' not in self.website:
            sys.exit('\nInvalid domain name, please try again')

        print('\n' + '='*40 + "\nOperating System %s detected\n" % osver)

        sqlcheck = s.call('service mariadb status &>/dev/null', shell=True)
        if sqlcheck != 0:
            sys.exit('Error: MariaDB is not running')

        confirm = raw_input(
            'Please ensure '
            'httpd/mariadb is set up and running (Y to confirm): ')

        if confirm.lower() not in ("yes", "y"):
            sys.exit('\nExiting script\n')

        packages = ('httpd', 'mariadb-server', 'mariadb', 'php', 'php-common',
                    'php-mysql', 'php-gd', 'php-xml', 'php-mbstring',
                    'php-mcrypt')

        print('Checking for missing packages\n')

        for i in packages:
            one = s.call('rpm -qa | grep %s &>/dev/null' % i, shell=True)
            if one != 0:
                print('Warning %s is not installed' % i)

        print('Package checking complete')

        if os.path.exists('/var/www/html/' + self.website):
            exit('\nError: Directory for %s already exists\n' % self.website)

    def wordpress(self):

        website_path = '/var/www/html/'
        website_full = website_path + self.website
        db = sql.connect("localhost", "root", "asdasd_324")
        cursor = db.cursor()
        dbname = self.website.split('.')[0][0:6] + '_wp'
        wp_dl = 'https://wordpress.org/latest.tar.gz'
        wp_tar = '/tmp/wp.tar.gz'

        print('\nExtracting Wordpress Files\n')

        urllib.urlretrieve(wp_dl, wp_tar)
        tar_file = tarfile.open(wp_tar, 'r:gz')
        tar_file.extractall(website_path)
        os.rename(website_path + 'wordpress', website_full)

        print('Creating Database for %s' % dbname)

        cursor.execute('create database if not exists %s' % dbname)
        cursor.execute(
            "grant all privileges on %s.* to %s@localhost identified by\
            'asdasd_324'" % (dbname, dbname))
        cursor.execute('flush privileges')

        print('\nInserting settings into wp-config')

        os.rename(
            website_full +
            '/wp-config-sample.php', website_full + '/wp-config.php')
        with open(website_full + '/wp-config.php', 'r') as f:
            r = f.read()
        with open(website_full + '/wp-config.php', 'w') as f:
            r = r.replace('database_name_here', dbname)
            r = r.replace('username_here', dbname)
            r = r.replace('password_here', 'asdasd_324')
            f.write(r)
        s.call('chown -R apache:apache %s' % website_full, shell=True)
        db.close()

    def httpset(self):

        if not os.path.exists('/var/log/apache/'):
                os.makedirs('/var/log/apache/')

        site1 = '/etc/httpd/sites-enabled' + '/' + self.website
        site2 = """<VirtualHost *:80>
        ServerName {0}
        ServerAlias www.'{0}' mail.{0}
        DocumentRoot /var/www/html/{0}/
        RewriteEngine on
        CustomLog /var/log/apache/{0}-log combined
        ErrorLog /var/log/apache/{0}-errorlog
        <Directory '/var/www/html/{0}/'>
        AllowOverride All
        </Directory>
        RewriteCond %{{SERVER_NAME}} =mail.{0} [OR]
        RewriteCond %{{SERVER_NAME}} =www.{0} [OR]
        RewriteCond %{{SERVER_NAME}} ={0}
        </VirtualHost>""".format(self.website)

        if not os.path.exists('/etc/httpd/sites-enabled'):
            os.mkdir('/etc/httpd/sites-enabled')

        if not os.path.exists(site1):
            with open(site1, 'w') as f:
                f.write(site2)
        else:
            print('%s already exists within the directory: %s'
                  % (self.website, site1))
        s.call('service httpd restart', shell=True)


def main():

    website = raw_input(
            'Please insert website domain name you wish to install: ')

    global osver
    osver = platform.linux_distribution()[0]

    if osver == 'CentOS Linux':
        start = wp(website)
        start.check()
        start.wordpress()
        start.httpset()
    elif osver == 'Ubuntu':
        sys.exit('Ubuntu is not currently supported by this script')
    else:
        sys.exit('OS version not supported by this script')

    print('\nScript has completed\n')


if __name__ == '__main__':
    main()
