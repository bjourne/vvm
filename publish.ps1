.\dev.ps1
git add -f static
git add -f config.py
git commit . -m "temp heroku deploy commit"
git push heroku master --force
git reset --soft HEAD~1
git reset HEAD static
git reset HEAD config.py
