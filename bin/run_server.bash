#!/bin/bash
echo 'Running Server' &&
if [[ ! -f ./world-versions/${WORLD_NAME}/world-version ]]; then
  mkdir -p ./world-versions/${WORLD_NAME} &&
  echo 0 > ./world-versions/${WORLD_NAME}/world-version
fi  &&

aws s3 cp s3://minecraft-mcvicaria/server-${MINECRAFT_VERSION}/world-versions/${WORLD_NAME}/world-version ./world-versions/${WORLD_NAME}/remote-world-version &&
REMOTE_VERSION=`cat ./world-versions/${WORLD_NAME}/remote-world-version | sed 's/\r$//'` &&
MY_VERSION=`cat ./world-versions/${WORLD_NAME}/world-version` &&
echo "Remote version: $REMOTE_VERSION" &&
echo "My version: $MY_VERSION" &&
if [ "$REMOTE_VERSION" -gt "$MY_VERSION" ]; then
        MY_VERSION=$REMOTE_VERSION &&
        echo "Downloading latest world." &&
        rm -rf ./$WORLD_NAME &&
        aws s3 sync s3://minecraft-mcvicaria/server-${MINECRAFT_VERSION}/${WORLD_NAME} ./${WORLD_NAME}
fi &&
if [[ -f ./world-versions/${WORLD_NAME}/remote-world-version ]]; then
        rm ./world-versions/${WORLD_NAME}/remote-world-version
fi &&
MY_VERSION=$(($MY_VERSION+1)) &&
echo $MY_VERSION > ./world-versions/${WORLD_NAME}/world-version &&

sed -e "s/{{level_name}}/${WORLD_NAME}/g" -e "s/{{rcon_pwd}}/${MCRCON_PWD}/g" server.properties.tmpl > server.properties &&

java -Xmx4096M -Xms4096M -jar server.jar nogui &&

aws s3 rm s3://minecraft-mcvicaria/server-${MINECRAFT_VERSION}/${WORLD_NAME} --recursive &&
aws s3 cp ./${WORLD_NAME} s3://minecraft-mcvicaria/server-${MINECRAFT_VERSION}/${WORLD_NAME} --recursive &&
aws s3 cp ./world-versions/${WORLD_NAME}/world-version s3://minecraft-mcvicaria/server-${MINECRAFT_VERSION}/world-versions/${WORLD_NAME}/world-version;
echo 'Goodbye';
