#!/bin/bash
git add -f static
git commit . -m "temp heroku deploy commit"
git push heroku master --force
git reset --soft HEAD~1
git reset HEAD static
