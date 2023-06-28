FROM bitnami/keycloak:21.1.1

USER root

RUN apt-get update && \
    apt-get install -y curl

ENV KEYCLOAK_PROVIDER=/opt/bitnami/keycloak/providers/
ENV KEYCLOAK_BCRYPT_VERSION=1.5.3

RUN curl -L https://github.com/leroyguillaume/keycloak-bcrypt/releases/download/$KEYCLOAK_BCRYPT_VERSION/keycloak-bcrypt-$KEYCLOAK_BCRYPT_VERSION.jar > $KEYCLOAK_PROVIDER/keycloak-bcrypt-$KEYCLOAK_BCRYPT_VERSION.jar

USER 1001
