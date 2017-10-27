#!/usr/bin/python
import subprocess as s
import platform
import os
import MySQLdb as sql
import shutil


class wpremove():

    def __init__(self, website):
        self.website = website

    def check(self):

        print("This is a script to remove existing wordpress installation")

        if len(self.website) < 3 or '.' not in self.website:
            exit("Please enter valid domain name")

        sqlcheck = s.call('service mariadb status &> /dev/null', shell=True)
        if sqlcheck != 0:
            exit('Error: Mariadb is not running')

        confirm = raw_input('Please confirm you wish to remove %s, this is '
                            'not reversable: ' % self.website)

        if confirm.lower() not in ('y', 'yes'):
            exit('Aborting Removal Script for %s' % self.website)

        if not os.path.exists('/var/www/html/%s' % self.website):
            exit("Wordpress install for %s does not exist" % self.website)

    def removal(self):

        website_path = '/var/www/html/' + self.website
        db = sql.connect('localhost', 'root', 'password123', 'mysql')
        cursor = db.cursor()
        dbname = self.website.split('.')[0][0:6] + '_wp'

        print('Removing database if exists for %s' % self.website)
        cursor.execute('drop database if exists %s' % dbname)
        cursor.execute("delete from user where User = '%s'" % dbname)

        db.commit()
        db.close()

        print('Removing wordpress directory')

        try:
            shutil.rmtree(website_path)
        except:
            print('Unable to remove wordpress directory')

        vhost = '/etc/httpd/sites-enabled/' + self.website
        if os.path.exists(vhost):
            os.remove(vhost)

        s.call('service httpd restart', shell=True)


def wpcheck():

    list = os.listdir('/etc/httpd/sites-enabled')
    print('\nWordpress Installs found within this server are:\n')
    for i in list:
        if "wp-config.php" in os.listdir('/var/www/html/' + i):
            print i


def main():

    global osver
    wpcheck()
    website = raw_input('\nPlease insert website you wish to uninstall: ')

    osver = platform.linux_distribution()[0]

    if osver == 'CentOS Linux':
        site = wpremove(website)
        site.check()
        site.removal()
    else:
        exit('OS not supported by this script')


if __name__ == "__main__":
    main()
