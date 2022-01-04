FROM ubuntu:focal

ARG MINECRAFT_VERSION

WORKDIR /opt/minecraft_server

EXPOSE 25565/tcp
EXPOSE 25575/tcp

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install awscli openjdk-17-jdk -y 

COPY lib/${MINECRAFT_VERSION}/server.jar server.jar
COPY bin bin

RUN chmod 555 ./bin/run_server.bash && sed -i 's/\r$//' ./bin/run_server.bash
RUN echo "eula=true">eula.txt
COPY server.properties.tmpl server.properties.tmpl

CMD bash ./bin/run_server.bash
