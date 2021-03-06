#!/bin/bash

# Author: https://github.com/marblenix/

# Used in conjunction with the apt-mirror script to clear out the "hash
# sum mismatch" errors.

# To make this script work:
# 1. Replace $mirror with the URL of the one rysinc mirror closest to you.
# 2. Replace $local_mirror with the path to your backup on your machine.

# Best thing to do would be to copy the contents of this file into your
# postmirror.sh script, normally in $base_path/var/postmirror.sh You can
# find your $base_path from your apt-mirror configuration file.

mirror="http://us.archive.ubuntu.com/ubuntu/dists" # /ubuntu/dists/raring-security/main/binary-i386/Packages.bz2
local_mirror="/var/www/ubuntu/dists"
dist_names="$(for dist in $local_mirror/*; do basename $dist; done | sort --unique)"
repos=('main' 'restricted' 'universe' 'multiverse')

for dist in $dist_names; do
  curl --silent -L $mirror/$dist/Release                          -o $local_mirror/$dist/Release
  curl --silent -L $mirror/$dist/Release.gpg                      -o $local_mirror/$dist/Release.gpg
  for repo in ${repos[@]}; do
    echo "Updating $dist/$repo"
    mkdir -p $local_mirror/$dist/$repo/{source,binary-i386}
    curl --silent -L $mirror/$dist/$repo/source/Release           -o $local_mirror/$dist/$repo/source/Release
    curl --silent -L $mirror/$dist/$repo/source/Sources.bz2       -o $local_mirror/$dist/$repo/source/Sources.bz2
    curl --silent -L $mirror/$dist/$repo/source/Sources.gz        -o $local_mirror/$dist/$repo/source/Sources.gz
    curl --silent -L $mirror/$dist/$repo/source/Sources           -o $local_mirror/$dist/$repo/source/Sources
    curl --silent -L $mirror/$dist/$repo/binary-i386/Packages.bz2 -o $local_mirror/$dist/$repo/binary-i386/Packages.bz2
    curl --silent -L $mirror/$dist/$repo/binary-i386/Packages.gz  -o $local_mirror/$dist/$repo/binary-i386/Packages.gz
    curl --silent -L $mirror/$dist/$repo/binary-i386/Packages     -o $local_mirror/$dist/$repo/binary-i386/Packages
    curl --silent -L $mirror/$dist/$repo/binary-i386/Release      -o $local_mirror/$dist/$repo/binary-i386/Release
  done
done

# Clean 0B files
for file in $(for i in $(find "$local_mirror" | grep --color=none 'Packages$'); do file "$i"; done | grep "empty" | awk -F\: '{print $1}'); do
  rm -f $file
done
