#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')  # Always put this in Bourne shell scripts

#Check count of command line parameters
if [ "$#" -eq 0 ] ; then
  echo "Usage: $0 [--bzip2|--gzip|--xz] <path to local cifp file>" >&2
  echo "eg. $0 --bzip2 ./www.aeronav.faa.gov/Upload_313-d/cifp/cifp_201704.zip"    >&2
  exit 1
fi

# Parse command line arguments.
OUTPUT="db"
for arg in "$@"; do
  case "$arg" in
    -b | --bzip2)
      OUTPUT="bzip2"
      ;;
    -g | --gzip)
      OUTPUT="gzip"
      ;;
    -x | --xz)
      OUTPUT="xz"
      ;;
    *)
      sourceZip="$arg"
      ;;
  esac
done

if [ ! -f "$sourceZip" ]; then
    echo "$sourceZip doesn't exist" >&2
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

# Export the database file in the appropriate format.
case "$OUTPUT" in
  bzip2)
    bzip2 --best --force --stdout $workdir/cifp-"$cycle".db > "${sourceZip%.*}".db.bz2
    ;;
  db)
    cp $workdir/cifp-"$cycle".db "${sourceZip%.*}".db
    ;;
  gzip)
    gzip --best --force --stdout $workdir/cifp-"$cycle".db > "${sourceZip%.*}".db.gz
    ;;
  xz)
    xz --extreme --force --stdout $workdir/cifp-"$cycle".db > "${sourceZip%.*}".db.xz
    ;;
esac
