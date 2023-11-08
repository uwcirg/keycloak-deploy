FROM quay.io/keycloak/keycloak:22.0
LABEL authors="vdls@uw.edu"

ENV KC_HOSTNAME=localhost
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin
ENV TINI_VERSION="v0.19.0"
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS="true"

WORKDIR /opt/keycloak

# Clean up the directory inside the container if it contains anything
RUN rm -rf ./themes/*

# Copy the directory from the local host to the container
COPY dev-data/realm data/import

RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore

ADD --chown=keycloak:keycloak "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" /opt/tini/bin/tini
RUN chmod -R 750 /opt/tini

ENTRYPOINT ["/opt/tini/bin/tini", "--"]

CMD ["/opt/keycloak/bin/kc.sh","start-dev","--import-realm"]