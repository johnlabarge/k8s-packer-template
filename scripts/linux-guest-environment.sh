#!/bin/sh

#######################################
## Linux Guest Environment
curl -O https://packages.cloud.google.com/yum/doc/yum-key.gpg
curl -O https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
rpm --import yum-key.gpg --quiet
rpm --import rpm-package-key.gpg --quiet
rm yum-key.gpg
rm rpm-package-key.gpg 
yum updateinfo
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
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
yum updateinfo
yum install -y python-google-compute-engine \
google-compute-engine-oslogin \
google-compute-engine
for pkg in ${PKG_LIST[@]}; do
   yum install -y $pkg
done
sudo yum -y update
### END Linux Guest Environment #######


