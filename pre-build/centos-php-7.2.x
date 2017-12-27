# Donwload libsodium
cd "$root_dir/downloads"
libsodium=libsodium-1.0.16.tar.gz
if [[ ! -f $libsodium ]]; then
    curl -# -K - <<URL
        url = "https://download.libsodium.org/libsodium/releases/$libsodium"
        output = "$libsodium"

        url = "https://download.libsodium.org/libsodium/releases/$libsodium.sig"
        output="$libsodium.sig"
URL
    # Import the public key
    gpg --import "$root_dir/signatures/libsodium.gpg.asc"
    # Set as trusted source
    gpg --with-colon --fingerprint 'Frank Denis' | sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\1:6:/p' | gpg --import-ownertrust
    # Check integrity
    ! gpg --verify "$libsodium.sig" "$libsodium" &> /dev/null && {
        echo "File corrupted: $libsodium"
        exit
    }
fi
sdir=${libsodium%.tar.gz}
[[ ! -d "$sdir" ]] && tar xzvf "$libsodium"

found=`whereis libsodium | awk -F: '{if ($2 != "") print "yes"; else print "no";}'`
[[ $found == 'no' ]] && cd "$sdir" && ./configure --prefix=/usr && make && make check && $userdo make install

found=`whereis libzip | awk -F: '{if ($2 != "") print "yes"; else print "no";}'`
if [[ $found == 'no' ]]; then
    # Require to compile libzip
    $userdo yum -y install zlib-devel bzip2-devel
    # Download libzip, so far I did not find signature the skip integrity checking
    curl -# -O https://libzip.org/download/libzip-1.3.2.tar.gz
    tar xzvf libzip-1.3.2.tar.gz
    cd libzip-1.3.2
   ./configure --prefix=/usr && make && $userdo make install && $userdo ln -s /usr/lib/libzip.so.5.0.0 /usr/lib64/libzip.so.5 
fi

