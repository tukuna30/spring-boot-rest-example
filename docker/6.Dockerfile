# syntax=docker/dockerfile:experimental

#----
# Build Stage
FROM maven:3.6.1-ibmjava-8-alpine as build

RUN mkdir -p /usr/app
WORKDIR /usr/app

# copy Maven dependency
COPY pom.xml .

RUN --mount=type=cache,target=/root/.m2 mvn -T 1C install && rm -rf target

# copy app source
COPY src/main /usr/app/src/main

# compile
RUN --mount=type=cache,target=/root/.m2 mvn -T 1C compile

#----
# Test Stage
FROM build as test

# copy app source
COPY src/test /usr/app/src/test

# run tests
RUN --mount=type=cache,target=/root/.m2 mvn -T 1C -o test

#----
# Package Stage
FROM build as package
# package app
RUN --mount=type=cache,target=/root/.m2 mvn package -T 1C -o -Dmaven.test.skip=true

#----
# Release Stage
FROM openjdk:8-jre-alpine as prerelease

COPY --from=package /usr/app/target/spring-boot-rest-example-0.5.0.war /app.war

#----
# Security Scan Stage
FROM prerelease as scan
ADD https://get.aquasec.com/microscanner .
RUN chmod +x microscanner
RUN --mount=type=secret,id=token ./microscanner $(cat /run/secrets/token)

#----
# Release stage
FROM prerelease as release

RUN adduser -D appuser
USER appuser

EXPOSE 8090
EXPOSE 8091

# run app
CMD ["java", "-jar", "-Dspring.profiles.active=test", "app.war"]

