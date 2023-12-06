FROM quay.io/keycloak/keycloak:22.0
LABEL authors="vdls@uw.edu"

ENV KC_HOSTNAME=localhost
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true
ENV PATH="$PATH:/opt/keycloak/bin:/opt/keycloak/sbin"
ENV KEYCLOAK_BACKUP_DIR="/opt/keycloak/backup"

WORKDIR /opt/keycloak

# Clean up the directory inside the container if it contains anything
RUN rm -rf ./themes/*

RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

ADD --chown=keycloak:keycloak "modules/system/src/main/sh/bin" /opt/keycloak/sbin
RUN chmod -R 750 /opt/keycloak/sbin

ENTRYPOINT ["entrypoint-wrapper.sh"]