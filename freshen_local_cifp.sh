#!/bin/bash
set -eu                 # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')    # Always put this in Bourne shell scripts

# Download latest documents from from FAA

# The script begins here
# Set some basic variables and make them read-only
PROGNAME=$(basename "$0")
PROGDIR=$(readlink -m "$(dirname "$0")")
NUMARGS=$#

declare -r PROGNAME
declare -r PROGDIR
declare -r NUMARGS

# Validate number of command line parameters
if [ "$NUMARGS" -ne 1 ] ; then
    echo "Usage: $PROGNAME <DOWNLOAD_ROOT_DIR>" >&2
    echo "eg: $PROGNAME ." >&2
    exit 1
fi

# Get command line parameter
DOWNLOAD_ROOT_DIR=$(readlink -f "$1")
declare -r DOWNLOAD_ROOT

if [ ! -d "$DOWNLOAD_ROOT_DIR" ]; then
    echo "$DOWNLOAD_ROOT_DIR doesn't exist" >&2
    exit 1
fi

# Use CIFP_URL if set, else get URL for current CIFP edition
if [ -n "${CIFP_URL:-}" ]; then
    cifp_url="${CIFP_URL}"
else
    cifp_url=$(./get_current_cifp_url.py)
fi

# Is CIFP_URL a file:/ URL?
if [[ "${CIFP_URL}" =~ ^file:/ ]]; then

    # Copy CIFP to the download directory (file:/ or file:/// URL)
    cifp_path=$(echo $CIFP_URL | sed -E 's/^file:\/(\/\/)?/\//')
    echo "Copying $cifp_path"
    cp $cifp_path "$DOWNLOAD_ROOT_DIR"
else

    # Update local cifp
    echo "Downloading $cifp_url"
    wget \
        --directory-prefix="$DOWNLOAD_ROOT_DIR"    \
        --timestamping      \
        --ignore-case       \
        "$cifp_url"
fi


