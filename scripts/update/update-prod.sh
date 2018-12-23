#!/bin/bash -e

# Updates production automatically by merging changes from stag to prod

git checkout stag
git pull
git checkout master
git pull
git merge stag
git push
git checkout dev
