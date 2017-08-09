FROM openjdk:alpine
LABEL maintainer=bcourlis@cisco.com

RUN mkdir -p /usr/local/petclinic

COPY ./target/spring-petclinic-1.5.1.jar /usr/local/petclinic

CMD ["java", "-jar", "/usr/local/petclinic/spring-petclinic-1.5.1.jar"]
