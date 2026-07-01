#!/bin/bash
cd /home/z/my-project/invensync_mobile
/home/z/flutter/bin/flutter build web --release --base-href "/invensync-mobile/" 2>&1
echo "BUILD EXIT: $?"