#!/bin/sh

#Basic Setup vars
PROJECT_ID=cloudjlb-packer-tutorial
IMAGE_FAMILY="acme-centos7"
IMAGE_ZONE="us-central1-f" 
BUCKET=cloudjlb-packer-tutorial-images-from-iso

#Remove any previously created images
if [[ -d output ]]; then
  rm -rf output 
fi

##############################################
## Create a key pair used for final 
## provisioning user include a .pem file for 
## use in the subsequent final gce build 
## since the pem file will be needed by the
## last build step, key is generated at the
## host and user provisioning script 
## created for the key.
##############################################

ssh-keygen -f provisioner -N ''

openssl rsa -in \
    provisioner -outform pem > provisioner.pem

NEWUSER='provisioner'
cat <<EOF >add-provisioner-user.sh
SSH_PUBLIC_KEY="\'$(cat provisioner.pub)\'"
adduser ${NEWUSER}
su - ${NEWUSER} -c \
    "umask 022; mkdir .ssh; \ 
     echo $SSH_PUBLIC_KEY >> \
     .ssh/authorized_keys" 
usermod -a -G wheel ${NEWUSER}
EOF

##############################################
## Build the partially provisioned image using 
## qemu/kvm
##############################################
packerio build *from-iso.json
if [[ -d output ]]; then
  echo "image created in output directory" 
else
  echo "Unable to create base image" 
  exit 1;
fi
###############################################
## Upload the new image file to GCS and create 
## the partially provisioned image
###############################################
echo "Uploading partially provisioned image to GCP" 
cd output
mv *image disk.raw
#TAG TODO REPLACE THIS WITH THE TAG 
TAG=$(date +%H%M)
FILENAME=centos-testv${TAG}.tar.gz
SOURCE_IMAGE="${IMAGE_FAMILY}-${BUILD_NUMBER}-partial"
IMAGE_NAME="${IMAGE_FAMILY}-${BUILD_NUMBER}"
tar -czf ${FILENAME} disk.raw
gsutil cp *.tar.gz gs://${BUCKET}
gcloud compute images create \
    $SOURCE_IMAGE --source-uri=gs://${BUCKET}/${FILENAME}

###############################################
## Build the final image using the provisioner 
## user
###############################################
echo "Finalizing provisioning of GCE Image" 
cmd="packerio build *from-partial.json \
  -var \"project_id=$PROJECT_ID\" \
  -var \"source_image=$SOURCE_IMAGE\" \
  -var \"image_name=$IMAGE_NAME\" \ 
  -var \"provisioner_key=provisioner.pem\""
echo $cmd
