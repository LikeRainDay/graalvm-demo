FROM harbor.pkulaw.cn:8443/base-img/graalvm-init:1.5 AS TMP

ADD . /build
WORKDIR /build

RUN gradle nativeCompile --info

# We use a Docker multi-stage build here in order that we only take the compiled native Spring Boot App from the first build container
FROM oraclelinux:7-slim

MAINTAINER houshuai@chinalawinfo.com

# Add Spring Boot Native app spring-boot-graal to Container
COPY --from=TMP "/build/build/native/nativeCompile/*" spring-boot-graal

# Fire up our Spring Boot Native app by default
CMD [ "sh", "-c", "./spring-boot-graal -Dserver.port=$PORT" ]