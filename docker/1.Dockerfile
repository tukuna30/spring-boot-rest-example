FROM maven:3.2-jdk-8

COPY ./target/spring-boot-rest-example-0.5.0.war /usr/app/

WORKDIR /usr/app

EXPOSE 8090
EXPOSE 8091

CMD ["mvn", "spring-boot:run", "-Drun.arguments=\"spring.profiles.active=test\""]
