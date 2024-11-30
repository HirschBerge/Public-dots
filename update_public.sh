#!/usr/bin/env bash

cd ~/projects/Public-dots/|| exit 1
git ls-files -z | xargs -0 rm -f
git restore ./santizie.sh ./.gitignore
fd --type d --type empty --exec rmdir {}
fd . "${FLAKE}" --exclude .git --max-depth 1 -X rsync -rah --info=progress2 {} ./
./santizie.sh
