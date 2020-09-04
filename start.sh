#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS=$(printf '\n\t')   # Always put this in Bourne shell scripts
mkdir -p /data/downloads


./freshen_local_cifp.sh /data/downloads && \
  FILE=$(ls /data/downloads) && \
  ./parseCifp.sh "/data/downloads/$FILE" && \
  cp *.db /data
