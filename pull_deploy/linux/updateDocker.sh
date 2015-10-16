#!/bin/bash
set -e
date # for logging
source vars.sh # this file contains all variables

DOCKER_RUN_COMMAND="docker run -d -p $PORT_MAPPING --name $BASE_IMAGE --restart=always -e \"APP_VERSION=$VERSION\" -v $CONFIG_FILE:/home/$BASE_IMAGE/config_override.properties $IMAGE:latest"

CID=$(docker ps | grep $IMAGE | awk '{print $1}')
docker pull $IMAGE

if [ $CID ]; then # if already running
   for im in $CID
      do
          LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
          RUNNING=`docker inspect --format "{{.Image}}" $im`
          NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
          echo "Latest:" $LATEST
          echo "Running:" $RUNNING
          if [ "$RUNNING" != "$LATEST" ];then
              echo "upgrading $NAME"
              docker stop $NAME
              docker rm -f $NAME
              echo "Running DOCKER_RUN_COMMAND"
              $DOCKER_RUN_COMMAND
          else
              echo "$NAME up to date"
          fi
   done
else
   echo "Running DOCKER_RUN_COMMAND"
   $DOCKER_RUN_COMMAND
fi