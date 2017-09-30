#!/usr/bin/python3

import subprocess as s
import os
import time
import tarfile
import shutil
import argparse
import sys

# Script to copy linuxpersonal website files


def parse_input():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--source', nargs=1, required=True,
                        help='Source backup location')
    parser.add_argument('-t', '--target', nargs=1, required=True,
                        help='Target backup location')

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()

    return parser.parse_args()


def backup():

    print('Creating backup of %s to %s' % (source, target))

    if not os.path.exists(target):
        os.makedirs(target)
    try:
        s.call('rsync -a %s %s' % (source, target), shell=True)
    except:
        sys.exit()


def compress():

    if os.path.exists(target):
        tar = tarfile.open(target + '.tar.gz', 'w:gz')
        tar.add(target, arcname='backup-root')
        tar.close()

        if os.path.exists(target + '.tar.gz'):
            shutil.rmtree(target)
    else:
        sys.exit()


if __name__ == '__main__':

    arg = parse_input()

    source = arg.source[0]
    target = arg.target[0] + '.' + time.strftime('%d-%Y')

    backup()
    compress()
