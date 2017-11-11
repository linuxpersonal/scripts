#!/usr/bin/python

import platform
import subprocess as s
import os

def main():

    print("Installing zsh and oh-my-zsh")
    print("Steps: 1-Install packages, 2-Install oh-my-zshm, 3-Install plugin")
    
    osver = platform.linux_distribution()[0]

    if osver == 'CentOS Linux':
        package = 'yum'
    elif osver == 'Ubuntu':
        package = 'apt'

    cmd1 = [package, 'install', '-y', 'zsh', 'wget', 'git']
    cmd2 = 'sh -c "$(wget https://raw.github.com/robbyrussell/'\
           'oh-my-zsh/master/tools/install.sh -O -)"'
    cmd3 = 'git clone https://github.com/zsh-users/'\
            'zsh-autosuggestions '\
            '/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions'
    ## Installing packages required for oh-my-zsh

    try:
        packages = s.Popen(cmd1, stdout=s.PIPE).communicate()[0]
    except Exception as e:
        print(e)

    if not os.path.exists('/root/.oh-my-zsh'):
        try:
            zsh_install = s.Popen(
                    cmd2, stdout=s.PIPE, shell=True).communicate()[0]
        except Exception as e:
            print(e)
    else:
        print("Skipping oh-my-zsh install: .oh-my-zsh directory exists")

    ## Installing oh-my-zsh

    if not os.path.exists('/root/.oh-my-zsh/custom/plugins/'\
            'zsh-autosuggestions'):
        try:
            zsh_plugin = s.Popen(
                    cmd3, stdout=s.PIPE, shell=True).communicate()[0]
        except Exception as e:
            print(e)
    else:
        print("Skipping plugin install: autosuggestion dir already exists")

    ## Adding plugin to .zshrc conf file

    if os.path.exists('/root/.zshrc'):
        with open('/root/.zshrc', 'r') as f:                                                                                                                                                                                                                                                            
            r = f.read() 
            if 'zsh-autosuggestions' not in r:
                with open('/root/.zshrc', 'w') as f:                                                                                                                                                                                                                                                            
                    r = r.replace('plugins=(git)', 
                                  'plugins=(git zsh-autosuggestions)')                                                                                                                                                                                                                                                                  
                    r = r.replace(                                                                                                                                                                                                                                                                                       
'''plugins=(                                                                                                                                                                                                                                                                                                             
  git                                                                                                                                                                                                                                                                                                                    
)                                                                                                                                                                                                                                                                                                                        
''', 
                    'plugins=(git zsh-autosuggestions)')
                    if 'robbyrussel' in r:
                        r = r.replace('ZSH_THEME="robbyrussell"',
                                      'ZSH_THEME="agnoster"')
                    f.write(r)
                print("Writing to file successfull")
            else:
                print("Skipping writing to file: zsh-autosuggestions"\
                        " already exists within .zshrc")

if __name__ == "__main__":
    main()
