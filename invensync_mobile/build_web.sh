#!/bin/bash
cd /home/z/my-project/invensync_mobile
/home/z/flutter/bin/flutter build web --release --base-href "/invensync-mobile/" 2>&1
echo "BUILD EXIT: $?"
if [ "$?" -eq 0 ]; then
  echo "BUILD SUCCESS"
else
  echo "BUILD FAILED"
  exit 1
fi