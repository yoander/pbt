#!/usr/bin/env bash
# GNU shell script to compile PHP
# --------------------------------------------------------------------
# Copyleft 2017 Yoander Valdés (sedlav) Rodríguez <http://www.librebyte.net/>
# This script is released under GNU GPLV3 licence
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

root_dir="$(cd "$(dirname "$0" )" && pwd )"
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
sha256=$(cat ./signatures/$php_file.sig)
[[ ! -f $metalink_file ]] && source ./template.metalink > $metalink_file
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
        curl -# -L --metalink file://$root_dir/metalinks/${php_file}.metalink || exit 2
    else # Fallback download method
        download=false
        while read mirror && [[ $download == false ]]; do
            curl -# -L `printf $mirror $php_file` -o $php_file
            if [[ "`sha256sum ./$php_file|awk 'print $1'`" != "$sha25" ]]; then
                echo Corrupted file ($php_file)!
                exit 3
            fi
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
[[ -f /etc/os-release ]] && { source /etc/os-release; os_id=$ID; }
#
# Installing dependencies
# Common dependencies
# Replace minor release by an x, 7.2.0 => 7.2.x
php_mayor_revision=php-`echo $php_version|sed -r 's/\.[[:digit:]]+$/.x/'`
#actions=`echo $databases|sed -r 's/([[:alpha:]]+)/'$os_id'-\1/g'|xargs -I{} echo {} "$os_id $os_id-$web_server $os_id-$php_mayor_revision $os_id-$sysinit"`
actions="`cat <<ACTIONS
$os_id \
${os_id}-${web_server} \
${os_id}-${php_mayor_revision} \
${os_id}-${sysinit}
ACTIONS` `echo $databases|sed -r 's/([[:alpha:]]+)/'$os_id'-\1/g'`"

# echo $actions
for action in $actions; do
    depfile="$root_dir/os/${action}"
    [[ -f $depfile ]] && source $depfile $userdo
done
#
# Compilation params
if [[ "$install_prefix" =~ ^/usr/local/?$ ]]; then
	install_prefix=/usr/local
    sysconfdir=$install_prefix/etc/php
elif [[ "$install_prefix" =~ ^/usr/?$ ]]; then
	install_prefix=/usr
    sysconfdir=/etc/php
else
    echo "Invalid install dir: $install_prefix"
    exit 4;
fi

EXTENSION_DIR=$install_prefix/lib/php/modules
export EXTENSION_DIR
PEAR_INSTALLDIR=$install_prefix/share/pear
export PEAR_INSTALLDIR
#
# Create conf dirs
echo Created $sysconfdir, $sysconfdir/conf.d, $EXTENSION_DIR, $PEAR_INSTALLDIR
[[ ! -d "$sysconfdir" ]] && mkdir -p $sysconfdir/conf.d && echo Created $sysconfdir, $sysconfdir/conf.d
[[ ! -d "$EXTENSION_DIR" ]] && mkdir -p $EXTENSION_DIR && echo Created $EXTENSION_DIR
[[ ! -d "$PEAR_INSTALLDIR" ]] && mkdir -p $PEAR_INSTALLDIR && echo Created $PEAR_INSTALLDIR 
#
# New icu libs for intl does not include this stdc++ lib ld flag
EXTRA_LIBS=-lstdc++
export EXTRA_LIBS

cd "php-${php_version}"

if [ ! -f ./configure ]; then
    ./buildconf --force # Build configure, not included in git versions
fi

extension_names=`cat <<EXT
extensions-common \
extensions-${php_mayor_revision} \
extensions-${sysinit} \
extensions-${databases} \
extensions-${php_mode} \
extensions-${thread_model}
EXT`
extensions=
for extension_name in $extension_names; do
    ext_file="$root_dir/extensions/${extension_name}.conf"
    echo $ext_file
    [[ -f "$ext_file" ]] && extensions="$extensions `source $ext_file`"
done

./configure "$extensions"

export LDFLAGS="$LDFLAGS -lpthread"

make && make install

