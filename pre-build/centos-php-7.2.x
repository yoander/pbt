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

