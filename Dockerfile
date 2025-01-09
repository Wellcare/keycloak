FROM bitnami/keycloak:26.0.6

USER 1001

COPY --chown=1001:0 themes /opt/bitnami/keycloak/themes
COPY --chown=1001:0 providers /opt/bitnami/keycloak/providers

RUN /opt/bitnami/keycloak/bin/kc.sh build