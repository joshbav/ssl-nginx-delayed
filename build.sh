docker build --squash -t joshbav/ssl-nginx-delayed:$1 .
docker push joshbav/ssl-nginx-delayed:$1
echo
echo
echo Uploading all files to github.com/joshbav/ssl-nginx-delayed
echo
# All files to automatically be added
git add *
git config user.name “joshbav”
git commit -m "scripted commit $(date +%m-%d-%y)"
git push -u origin master
