#!/usr/bin/env bash
# GNU shell script to compile PHP
# --------------------------------------------------------------------
# Copyleft 2014 Yoander Valdés Rodríguez <http://www.librebyte.net/>
# This script is released under GNU GPL 2+ licence
# --------------------------------------------------------------------
# It's intended to use as helper for PHP compilation process.
# Enable the most used extensions as: curl, openssl, intl, mysql,
# pcre, ... and allows to install PHP in custom dir, offers options
# to compile PHP with Apache (prefork or worker) or fpm support.
# --------------------------------------------------------------------
#
# Argument testing
#
#if [[ $# == 0 ]]; then
#    echo Wrong number of args type -h for help.
#    exit 1    
#elif [[ ! -d "$1" ]]; then 
#    echo Php source is not valid directory
#    exit 2
#elif [[ "$@" =~ \-a.*\-?f ]]; then
#    echo -a and -f are exclusive options
#    exit 3 
#fi
#
# Global variables
#
main_conf=
userdo=
#
# Testing if you have root access!
if [[ 'root' == whoami ]]; then
    is_root=true
else
    is_root=false
fi

if [[ $is_root == false ]]; then
    userdo=$(which sudo)
    if [[ $userdo != '' ]]; then
        $userdo ls /root/ &>/dev/null && is_root=true 
    fi 
fi

if [[ $is_root == false ]]; then      
    echo This script requires root access
    echo Bye!
    exit 1
fi  
#
# Load configuration
source ./pbt.ini
php_file=php-${php_version}.${compression}
#
# create metalinks dir if no exists
[[ ! -d ./metalinks ]] && mkdir metalinks
#
# If metalink does no exits generate it based on metalink template
metalink_file=./metalinks/${php_file}.metalink 
[[ ! -f $metalink_file ]] && source ./template.metalink $php_file $(cat ./signatures/$php_file.sig) > $metalink_file
#
# Create downloas dir
[[ ! -d ./downloads ]] && mkdir downloads
#
# Move to downloads dir
cd ./downloads
#
# Download PHP, if the file is not already downloaded, if the file was downloaded partially then delete it
if [[ ! -f ./$php_file ]]; then
    if [[ `curl -V|grep -i 'features:.*\bmetalink\b'` ]]; then # Test for metalink support
	curl -# -L --metalink file://$(pwd)/../metalinks/${php_file}.metalink || exit 2
    else # Fallback download method
        download=false
        while read mirror && [[ $download == false ]]; do
	   curl -# -L `printf $mirror $php_file` -o $php_file
	   download=$?	 
	done < ./../mirrors.txt
	[[ ! $? ]] && exit    	
    fi
fi
#
# Uncompressing: Uncompress only if the php-${php_version} dir does not exist to uncompress again delete the dir
if [[ ! -d ./php-${php_version} ]]; then
    if [[ 'tar.xz' == $compression ]]; then
       tar xvJf $php_file
    elif [[ 'tar.bz2' == $compression ]]; then 
       tar xvjf $php_file
    elif [[ 'tar.gz' == $compression ]]; then
       tar xvzf $php_file
    else
       echo "Uknown file ($php_file) compression"
       echo Bye!
       exit 2
    fi
fi
#
# Load OS details
#
[[ -f /etc/os-release ]] && { source /etc/os-release; os_id=$ID; }
#
# Installing dependencies
#
depfile=./../os/${os_id}

[[ -f $depfile ]] && source $depfile $userdo
