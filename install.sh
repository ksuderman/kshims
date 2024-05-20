#!/usr/bin/env bash

REPO="https://raw.githubusercontent.com/ksuderman/kshims/master"
KUBE=~/.kube
BIN=$KUBE/bin
CONFIGS=$KUBE/configs
CONFIG=$KUBE/config

if [[ ! -e $BIN ]] ; then
  mkdir -p $BIN
fi
if [[ ! -e $CONFIGS ]] ; then
  mkdir -p $CONFIGS
fi
curl -s $REPO/bin/kshim > $BIN/kshim
curl -s $REPO/bin/shim > $BIN/shim
chmod +x $BIN/shim $BIN/kshim

$BIN/kshim link kubectl
$BIN/kshim link helm
$BIN/kshim init >> ~/.bash_profile
export PATH=$BIN:$PATH

echo "kshim has been installed and shims for kubectl and helm have been created."
kubectl confess
helm confess


