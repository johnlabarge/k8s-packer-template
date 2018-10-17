packerio build \
-var "project_id=cloudjlb-packer-tutorial" \
-var "source_image=acme-centos7--partial" \
-var "image_name=acme-centos7-complete" \
-var "image_zone=us-central1-b" \
-var  "private_key_file=provisioner" \
*-from-partial.json
