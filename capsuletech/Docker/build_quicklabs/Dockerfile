FROM debian:bullseye-slim AS builder
ENV GOPATH /root/work
ENV GOCACHE /root/.cache/go-build
ENV GRADLE_HOME /opt/gradle-6.8.3
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64"
ENV PATH "${PATH}:/usr/local/go/bin:/opt/gradle-6.8.3/bin"
RUN mkdir -p /usr/share/man/man1 \
&& apt update -y \
&& apt install -y curl zip build-essential openjdk-11-jdk protobuf-compiler git \
&& curl -L -o /root/go1.15.11.linux-amd64.tar.gz https://dl.google.com/go/go1.15.11.linux-amd64.tar.gz \
&& tar -xvf /root/go*.tar.gz -C /root \
&& mv /root/go /usr/local \
&& mkdir -p /root/work /root/.cache/go-build \
&& curl -L -o /tmp/gradle-6.8.3-bin.zip https://services.gradle.org/distributions/gradle-6.8.3-bin.zip \
&& unzip -d /opt /tmp/gradle-*.zip
WORKDIR /root
RUN git clone https://github.com/GoogleCloudPlatform/healthcare-data-harmonization.git \
&& git clone https://github.com/GoogleCloudPlatform/healthcare-data-harmonization-dataflow.git
WORKDIR /root/healthcare-data-harmonization
RUN ./build_all.sh
WORKDIR /root/healthcare-data-harmonization-dataflow
RUN gradle wrapper --gradle-version 6.8.3 \
&& ./gradlew shadowJar \
&& mv /root/healthcare-data-harmonization-dataflow/build/libs/converter-0.1.0-all.jar /root/converter-0.1.0-all.jar
FROM openjdk:11-jdk-slim-buster
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64"
RUN mkdir /usr/lib/jvm \
&& ln -snf /usr/local/openjdk-11 /usr/lib/jvm/java-8-openjdk-amd64 \
&& ln -snf /usr/lib/jvm/java-8-openjdk-amd64/bin/java /etc/alternatives/java
WORKDIR /root/
COPY --from=builder /root/converter-0.1.0-all.jar .
