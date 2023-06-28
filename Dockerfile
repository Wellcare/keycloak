FROM bitnami/keycloak:latest

USER root

# Install required tools
RUN apt-get update && \
    apt-get install -y curl

# Install jbcrypt module
RUN curl https://repo1.maven.org/maven2/org/mindrot/jbcrypt/0.4/jbcrypt-0.4.jar > /tmp/jbcrypt-0.4.jar && \
    $KEYCLOAK_HOME/bin/jboss-cli.sh --command="module add --name=org.mindrot.jbcrypt --resources=/tmp/jbcrypt-0.4.jar"

# Install keycloak-bcrypt plugin
RUN curl -L https://github.com/leroyguillaume/keycloak-bcrypt/releases/download/1.5.3/keycloak-bcrypt-1.5.3.jar > $KEYCLOAK_HOME/standalone/deployments/keycloak-bcrypt-1.5.3.jar

USER 1001
