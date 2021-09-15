#!/bin/bash

# check for config file
if [ ! -e $HOME/.website ]; then
  echo ""
  echo -e '\033[7;31m'"$HOME/.website does not exist"'\033[0m'
  echo "place website directory in 1st line"
  echo "place website html repository in 2nd line"
  echo ""
  exit 1
fi

# read config file
config=$(head -n 2 $HOME/.website)
directory=$(echo $config | cut -d ' ' -f 1)
repository=$(echo $config | cut -d ' ' -f 2)
directory="${directory/#\~/$HOME}"

# does the website exist?
if [ -e $directory ]; then
  cd $directory
else
  echo -e '\033[7;31m'"website directory ($directory) does not exist"'\033[0m'
  exit 1
fi

# clean up previous builds
rm -rf public
git rm public
rm -rf .git/modules/public
git submodule update --init --recursive
git submodule add -f -b master $repository public

# build the website
docker run \
  --rm -it \
  -v $PWD:/src \
  -u $(id -u):$(id -g) \
  klakegg/hugo:ext

# push the website
cd public/
git add .
git commit -m "Build Website"
git push origin master

# delete the built website
cd .. && rm -rf public

# update website source on git 
git add .
git commit -m "Update Website Source"
git push origin master

exit 0
