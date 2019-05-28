FROM maven:3.2-jdk-8

COPY . /usr/app/

WORKDIR /usr/app

RUN mvn clean package

EXPOSE 8090
EXPOSE 8091

CMD ["mvn", "spring-boot:run", "-Drun.arguments=\"spring.profiles.active=test\""]
