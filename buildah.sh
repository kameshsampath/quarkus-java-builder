#!/bin/bash 

# WORK_DIR  the directory where the application binaries are built
# DESTINATION_NAME  - the fully qualified destination image name where the 
# MVN_CMD_ARGS - the maven command arguments e.g. clean install
# build image will deployed e.g. quay.io/myrepo/app:1.0

set -xeu

cd $WORK_DIR

# build the java project 
mvn ${MVN_CMD_ARGS:-clean -DskipTests install -Pnative}

# define the container base image
containerID=$(buildah from registry.fedoraproject.org/fedora-minimal)

# mount the container root FS
appFS=$(buildah mount $containerID)

# make the native app directory
mkdir -p $appFS/deployment

cp target/*-runner  $appFS/deployment/application

chmod +x $appFS/deployment/application

# Add entry  point for the application
buildah config --entrypoint $appFS/deployment/application $containerID
buildah config --cmd "['-Dquarkus.http.host=0.0.0.0']" $containerID

IMAGEID=$(buildah commit $containerID $DESTINATION_NAME)

echo "Succesfully committed $DESTINATION_NAME with image id $IMAGEID"

# Push the image to default regisry 
# TODO -  how to find the default registry 
#  
podman push $IMAGEID docker-daemon:$DESTINATION_NAME