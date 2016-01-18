#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
msg="rebuilding site `date`"
if [ $# -eq 1 ]
then msg="$1"
fi

hugo -D
git add -A
git commit -m "$msg"
git push -u origin master

cd public
git checkout master
git add -A
git commit -m "$msg"
git push --force -u origin master

git checkout gitcafe-pages
cd ../
hugo -D
cd public
git add -A
git commit -m "$msg"
git push --force -u gitcafe gitcafe-pages
git checkout master

cd ../
