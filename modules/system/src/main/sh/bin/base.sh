#!/bin/bash

export KEYCLOAK_START_CMD="/opt/keycloak/bin/kc.sh"
export EXPORT_USERS_SCRIPT="/opt/keycloak/sbin/export.sh"
export IMPORT_USERS_SCRIPT="/opt/keycloak/sbin/import.sh"
export KCADMIN="/opt/keycloak/bin/kcadm.sh"
export KC="/opt/keycloak/bin/kc.sh"
export KC_PID_FILE="/opt/keycloak/keycloak.pid"
export PATH="$PATH:/opt/keycloak/bin:/opt/keycloak/sbin:/opt/groovy/bin"

export LOG4J_FORMAT_MSG_NO_LOOKUPS=true

export KEYCLOAK_BACKUP_DIR="/opt/keycloak/backup"

export BACKUP_FILE_REALMS="realms.json"
export BACKUP_FILE_REALMS_PATH="$KEYCLOAK_BACKUP_DIR/$BACKUP_FILE_REALMS"

export KC_HOSTNAME=localhost
export KC_HTTP_ENABLED=true
export KC_HOSTNAME_STRICT_HTTPS=false
export KC_HOSTNAME_STRICT=false
export KC_PROXY=edge

export JAVA_HOME="/usr/lib/jvm/jre"
export GROOVY_HOME="/opt/groovy"