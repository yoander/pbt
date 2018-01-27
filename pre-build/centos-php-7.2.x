# Donwload libsodium
arch=$(getconf LONGBIT)
cd "$root_dir/downloads"
libsodium=libsodium-1.0.16.tar.gz
if [[ ! -f $libsodium ]]; then
    echo Downloading $libsodium
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
# Uncompress libsodium dir
libdir=${libsodium%.tar.gz}
[[ ! -d "$libdir" ]] && tar xzvf "$libsodium"

found=`whereis libsodium | awk -F: '{if ($2 != "") print "yes"; else print "no";}'`
[[ $found == 'no' ]] && {
    echo Compiling $libsodium
    cd "$libdir" 
    ./configure --prefix=/usr && make && make check && $userdo make install;
    # No error in last operation
	[[ $? ]] && \
        [[ $arch == 64 ]] && \
        [[ ! -f /usr/lib64/libsodium.so.23 ]] && \
        $userdo ln -s /usr/lib/libsodium.so.23 /usr/lib64/libsodium.so.23
}


found=`whereis libzip | awk -F: '{if ($2 != "") print "yes"; else print "no";}'`
if [[ $found == 'no' ]]; then
    cd "$root_dir/downloads"
    # Require to compile libzip
    $userdo yum -y install zlib-devel bzip2-devel
    # Download libzip, so far I did not find signature then skip integrity checking
    libzip=libzip-1.3.2.tar.gz
    echo Downloading libzip
    curl -# -O https://libzip.org/download/$libzip
    tar xzvf $libzip
    cd libzip-1.3.2
    cd "${libzip%.tar.gz}"
    echo Compiling libzip
    ./configure --prefix=/usr && make && $userdo make install 
    # No error in last operation
	[[ $? ]] && \
        [[ $arch == 64 ]] && \
        [[ ! -f  /usr/lib64/libzip.so.5 ]] && \
        $userdo ln -s /usr/lib/libzip.so.5.0.0 /usr/lib64/libzip.so.5
fi

