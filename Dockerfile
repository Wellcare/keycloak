FROM bitnami/keycloak:21.1.1

USER root

# Install required tools
RUN apt-get update && \
    apt-get install -y curl

# Install keycloak-bcrypt plugin
RUN curl -L https://github.com/leroyguillaume/keycloak-bcrypt/releases/download/1.5.3/keycloak-bcrypt-1.5.3.jar > $KEYCLOAK_HOME/standalone/deployments/keycloak-bcrypt-1.5.3.jar

USER 1001
