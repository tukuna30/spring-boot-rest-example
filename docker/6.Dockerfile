# syntax=docker/dockerfile:experimental
FROM maven:3.6.1-ibmjava-8-alpine as build

RUN mkdir -p /usr/app
WORKDIR /usr/app

# copy Maven dependency
COPY pom.xml .

RUN --mount=type=cache,target=/root/.m2 mvn -T 1C install && rm -rf target

# copy app source and tests
COPY src /usr/app/src

# run tests
RUN --mount=type=cache,target=/root/.m2 mvn -T 1C -o test

# package app
RUN --mount=type=cache,target=/root/.m2 mvn package -T 1C -o -Dmaven.test.skip=true

# release image
FROM openjdk:8-jre-alpine

RUN adduser -D appuser
USER appuser

COPY --from=build /usr/app/target/spring-boot-rest-example-0.5.0.war /app.war

EXPOSE 8090
EXPOSE 8091

# run app
CMD ["java", "-jar", "-Dspring.profiles.active=test", "app.war"]

