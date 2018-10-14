#!/bin/sh

#######################################
## Linux Guest Environment
# clear out yum metadata
OS_RELEASE_FILE="/etc/redhat-release"
if [ ! -f $OS_RELEASE_FILE ]; then
   OS_RELEASE_FILE="/etc/centos-release"
fi
DIST=$(cat $OS_RELEASE_FILE | grep -o '[0-9].*' | awk -F'.' '{print $1}')
sudo tee /etc/yum.repos.d/google-cloud.repo << EOM
[google-cloud-compute]
name=Google Cloud Compute
baseurl=https://packages.cloud.google.com/yum/repos/google-cloud-compute-el${DIST}-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0 #Something is off with this repo gpg and can't seem to get passed it
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
yum updateinfo
declare -a PKG_LIST=(python-google-compute-engine \
google-compute-engine-oslogin \
google-compute-engine)
for pkg in ${PKG_LIST[@]}; do
   sudo yum install -y $pkg
done
yum -y update
### END Linux Guest Environment #######
