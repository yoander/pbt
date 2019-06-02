arch=$(getconf LONG_BIT)
cd "$root_dir/downloads"
baseurl=https://ftp.pcre.org/pub/pcre
lib=pcre2-10.33.tar.bz2
echo "Downloading $baseurl/$lib";
if [[ ! -f $lib ]]; then
    echo Downloading $lib
    curl -#L -K - <<URL
        url = "$baseurl/$lib"
        output = "$lib"

        url = "$baseurl/Public-Key"
        output="$root_dir/signatures/Public-Key"
        
	url = "$baseurl/$lib.sig"
        output="$root_dir/signatures/$lib.sig"
	
URL
    # Import the public key
    gpg --import "$root_dir/signatures/Public-Key"
    # Set as trusted source
   # gpg --with-colon --fingerprint 'Frank Denis' | sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\1:6:/p' | gpg --import-ownertrust
    # Check integrity
    ! gpg --verify "$root_dir/signatures/$lib.sig" "$lib" &> /dev/null && {
        echo "File corrupted: $lib"
        exit
    }
fi
# Uncompress lib
libdir=${lib%.tar.bz2}
[[ ! -d "$libdir" ]] && tar xjvf "$lib"
found=$(find /usr/local/lib -type f -name 'libpcre2*' -print -quit)
[[ $found == 'no' ]] && {
    echo Compiling $libdir
    cd "$libdir" 
    ./configure --prefix=/usr/local \
            --enable-unicode \
            --enable-pcre2-16 \
            --enable-pcre2-32  \
            --enable-pcre2grep-libz \
            --enable-pcre2grep-libbz2 \
            --enable-pcre2test-libreadline \
	    --enable-jit=auto \
	    --enable-jit-sealloc \
            --disable-static                         && make && $userdo make install
}
