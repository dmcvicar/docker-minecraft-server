#!/bin/bash
echo 'Running Server' &&
if [[ ! -f ./world-versions/${WORLD_NAME}/world-version ]]; then
  mkdir -p ./world-versions/${WORLD_NAME} &&
  echo 0 > ./world-versions/${WORLD_NAME}/world-version
  CREATE_WORLD="true"
fi &&

if [ -z $CREATE_WORLD ]
  aws s3 cp s3://mcvicar-minecraft/server-${MINECRAFT_VERSION}/world-versions/${WORLD_NAME}/world-version ./world-versions/${WORLD_NAME}/remote-world-version
  REMOTE_VERSION=`cat ./world-versions/${WORLD_NAME}/remote-world-version | sed 's/\r$//'` &&
else
  REMOTE_VERSION=-1
fi && 
MY_VERSION=`cat ./world-versions/${WORLD_NAME}/world-version` &&
if [ "$REMOTE_VERSION" -gt "$MY_VERSION" ]; then
  MY_VERSION=$REMOTE_VERSION &&
  echo "Downloading latest world." &&
  rm -rf ./$WORLD_NAME &&
  aws s3 sync s3://mcvicar-minecraft/server-${MINECRAFT_VERSION}/${WORLD_NAME} ./${WORLD_NAME}
fi && 
if [[ -f ./world-versions/${WORLD_NAME}/remote-world-version ]]; then
  rm ./world-versions/${WORLD_NAME}/remote-world-version
fi &&
MY_VERSION=$(($MY_VERSION+1)) &&
echo $MY_VERSION > ./world-versions/${WORLD_NAME}/world-version &&

sed -e "s/{{level_name}}/${WORLD_NAME}/g" -e "s/{{rcon_pwd}}/${MCRCON_PWD}/g" server.properties.tmpl > server.properties &&

java -Xmx4096M -Xms4096M -jar server.jar nogui &&

aws s3 sync ./${WORLD_NAME} s3://mcvicar-minecraft/server-${MINECRAFT_VERSION}/${WORLD_NAME} --delete &&
aws s3 cp ./world-versions/${WORLD_NAME}/world-version s3://mcvicar-minecraft/server-${MINECRAFT_VERSION}/world-versions/${WORLD_NAME}/world-version;
echo 'Goodbye';
