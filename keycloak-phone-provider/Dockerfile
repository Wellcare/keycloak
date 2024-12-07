FROM maven:3.8-openjdk-17
WORKDIR /usr/keycloak
# RUN mkdir /target
COPY . .
RUN mvn clean package -DskipTests