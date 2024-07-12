FROM bitnami/keycloak:21.1.1

USER 1001

COPY --chown=1001:0 themes /opt/bitnami/keycloak/themes
COPY --chown=1001:0 providers /opt/bitnami/keycloak/providers

RUN /opt/bitnami/keycloak/bin/kc.sh build