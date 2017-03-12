FROM openjdk:8-jre-alpine

COPY spring-boot-*.war /app.war

CMD ["/usr/bin/java", "-jar", "-Dspring.profiles.active=test", "/app.war"]