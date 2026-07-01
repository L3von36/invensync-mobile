#!/bin/bash
cd /home/z/my-project/invensync_mobile
git add -A
git commit -m "Add Flutter web support with sql.js (Drift WebDatabase)

- Platform-conditional DB connection (NativeDatabase on mobile, WebDatabase on web)
- Added sql.js CDN to index.html for in-browser SQLite
- Updated SDK constraint to >=3.5.0 for broader compatibility
- Deployed to GitHub Pages: https://l3von36.github.io/invensync-mobile/"
git push 2>&1