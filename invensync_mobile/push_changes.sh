#!/bin/bash
cd /home/z/my-project/invensync_mobile
git add -A
git commit -m "Redesign login + add demo mode

- Split-layout login (branding panel + form) on wide screens
- Animated fade+slide entrance
- Fill Demo Credentials button (demo@invensync.com / demo1234)
- Try Demo Mode button (no server needed, seeds 12 products, 5 customers, 5 sales)
- Responsive design works on mobile and web" 2>&1
git push 2>&1