#!/bin/bash

needs_git=false
pkgman=""
echo "Checking to make sure git is installed"
if ! [ -x "$(command -v git)" ]; then
  echo 'git is not installed.' >&2
  needs_git=true
fi


if [ -x "$(command -v apt)" ]; then
  echo "apt detected"
  pkgman="apt"
  if [ $needs_git == true ]; then
    echo "Installing git"
    sudo apt update
    sudo apt install -y git
  fi


elif [ -x "$(command -v yum)" ]; then
  echo "yum detected"
  pkgman="yum"
  if [ $needs_git == true ]; then
    echo "Installing git"
    sudo yum update
    sudo yum install -y git
  fi
else
  echo 'ERROR: cannot determine package manager' >&2
  exit 1
fi


echo "Setting everything up from the Github Repo"
mkdir -p ~/github/patrickjmcd
git clone --recursive https://github.com/patrickjmcd/cloud9dotfiles ~/github/patrickjmcd/cloud9dotfiles
cd ~/github/patrickjmcd/cloud9dotfiles
make dev-$pkgman