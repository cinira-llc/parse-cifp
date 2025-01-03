#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

#Check count of command line parameters
if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 <path to local cifp file>" >&2
  echo "eg. $0 ./www.aeronav.faa.gov/Upload_313-d/cifp/cifp_201704.zip"    >&2
  echo "please run ./freshen_local_cifp.sh to update local CIFP data files first" >&2
  exit 1
fi

sourceZip="$1"

if [ ! -f "$sourceZip" ]; then
    echo "$sourceZip doesn't exist" >&2
    echo "please run ./freshen_local_cifp.sh to update local CIFP data files"   >&2
    exit 1
fi

# Process the supplied file name to get cycle number
# Save everything after 'cifp_'
sourceZipFilename=$(basename $sourceZip)
# 
tmp=${sourceZipFilename#*_}

# Remove the extension, leaving the cycle number
cycle=${tmp%.*}

# Where the CIFP data is unzipped to
workdir=`mktemp -d`

echo "Unzipping CIFP $cycle files"
unzip -u -j -q "$sourceZip"  -d "$workdir" > "$workdir/$cycle-unzip.txt"

# Delete any existing files
rm -f $workdir/cifp-"$cycle".db

echo "Creating the database"
# Create the sqlite database
./parseCifp.pl -c"$cycle" "$workdir/"

# Add indexes
echo "Adding indexes"
sqlite3 $workdir/cifp-"$cycle".db < addIndexes.sql

# Bzip2 compress and write to source directory, ".zip" replaced by ".db.bz2".
bzip2 --best --stdout $workdir/cifp-"$cycle".db > "${sourceZip%.*}".db.bz2
