FROM dokken/centos-7:latest

ADD . /build
WORKDIR /build

# For SDKMAN to work we need unzip & zip
RUN yum install -y gcc unzip zlib-devel

RUN \
    # Install SDKMAN
    curl -s "https://beta.sdkman.io" | bash; \
    source "$HOME/.sdkman/bin/sdkman-init.sh"; \
    # Install GraalVM Native Image
    gu install native-image;

RUN native-image --version

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && ./gradlew nativeCompile


# We use a Docker multi-stage build here in order that we only take the compiled native Spring Boot App from the first build container
FROM oraclelinux:7-slim

MAINTAINER houshuai@chinalawinfo.com

# Add Spring Boot Native app spring-boot-graal to Container
COPY --from=0 "/build/native/nativeCompile/graalvm" spring-boot-graal

# Fire up our Spring Boot Native app by default
CMD [ "sh", "-c", "./spring-boot-graal -Dserver.port=$PORT" ]