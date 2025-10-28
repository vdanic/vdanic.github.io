#!/bin/bash

echo -e "\033[0;32mDeploying updates to Coding...\033[0m"

# Removing existing files
rm -rf public/*
# Build the project
# hugo
# Go To Public folder
# cd public
# git remote rm origin
# git init
# git remote add origin git@101.33.220.102:/home/git/repos/blog-hugo.git
# git add .
# sudo git remote add origin git@github.com:vdanic/vdanic.github.io.git

git add .
# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"


# Push source and build repos.
git push origin master --force

# Come Back up to the Project Root
# cd ..

