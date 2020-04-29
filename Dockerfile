FROM ubuntu:bionic

WORKDIR /opt/minecraft_server

EXPOSE 25565/tcp
EXPOSE 25575/tcp

RUN apt-get update
RUN apt-get install awscli -y
RUN apt-get install openjdk-8-jdk -y

COPY bin bin
COPY lib lib

RUN chmod 555 ./bin/run_server.bash
RUN echo "eula=true">eula.txt
COPY server.properties.tmpl server.properties.tmpl

CMD bash ./bin/run_server.bash
