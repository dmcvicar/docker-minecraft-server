#!/bin/bash
echo 'Running Server' &&
if [[ ! -f ./world-version ]]; then
  echo 0 > world-version
fi  &&

aws s3 cp s3://minecraft-mcvicaria/server-$MINECRAFT_VERSION/world-version ./remote-world-version &&
REMOTE_VERSION=`cat ./remote-world-version | sed 's/\r$//'` &&
MY_VERSION=`cat ./world-version` &&
echo "Remote version: $REMOTE_VERSION" &&
echo "My version: $MY_VERSION" &&
if [ "$REMOTE_VERSION" -gt "$MY_VERSION" ]; then
        echo "Downloading latest world." &&
        rm -rf ./$WORLD_NAME &&
        aws s3 sync s3://minecraft-mcvicaria/server-$MINECRAFT_VERSION/$WORLD_NAME ./$WORLD_NAME &&
        rm -f ./world-version &&
        mv ./remote-world-version ./world-version &&
        MY_VERSION=$REMOTE_VERSION
fi &&
if [[ -f ./remote-world-version ]]; then
        rm ./remote-world-version
fi &&
MY_VERSION=$(($MY_VERSION+1)) &&
echo $MY_VERSION > ./world-version &&

RCON_PWD=`cat /run/secrets/mcrcon-pwd`
sed -e "s/{{level_name}}/${WORLD_NAME}/g" -e "s/{{rcon_pwd}}/${RCON_PWD}/g" server.properties.tmpl > server.properties

java -Xmx1024M -Xms1024M -jar lib/$MINECRAFT_VERSION/server.jar nogui;

aws s3 rm s3://minecraft-mcvicaria/server-$MINECRAFT_VERSION/$WORLD_NAME --recursive;
aws s3 cp ./$WORLD_NAME s3://minecraft-mcvicaria/server-$MINECRAFT_VERSION/$WORLD_NAME --recursive;
aws s3 cp ./world-version s3://minecraft-mcvicaria/server-$MINECRAFT_VERSION/world-version;
echo 'Goodbye';
