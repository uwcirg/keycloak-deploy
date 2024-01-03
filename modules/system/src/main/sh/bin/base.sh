#!/bin/bash

export KEYCLOAK_START_CMD="/opt/keycloak/bin/kc.sh"
export EXPORT_USERS_SCRIPT="/opt/keycloak/sbin/export.sh"
export IMPORT_USERS_SCRIPT="/opt/keycloak/sbin/import.sh"
export KCADMIN="/opt/keycloak/bin/kcadm.sh"
export KC="/opt/keycloak/bin/kc.sh"
export PATH="$PATH:/opt/keycloak/bin:/opt/keycloak/sbin"

export LOG4J_FORMAT_MSG_NO_LOOKUPS=true

export KEYCLOAK_BACKUP_DIR="/opt/keycloak/backup"
export EXPORT_FILE="keycloak-export.json"
export FULL_EXPORT_PATH="$KEYCLOAK_BACKUP_DIR/$EXPORT_FILE"

export KC_PROXY=edge
export KC_HOSTNAME_STRICT=false