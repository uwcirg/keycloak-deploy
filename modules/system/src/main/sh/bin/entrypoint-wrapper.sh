#!/bin/bash

KEYCLOAK_START_CMD="/opt/keycloak/bin/kc.sh"
EXPORT_USERS_SCRIPT="/opt/keycloak/sbin/export.sh"
IMPORT_USERS_SCRIPT="/opt/keycloak/sbin/import.sh"

modify_keycloak_start_cmd() {
    if [ "$KEYCLOAK_DEV_MODE" == true ]; then
        KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD start-dev"
    else
       KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD start"
    fi

    if [ "$KEYCLOAK_STARTUP_IMPORT" == true ]; then
        KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD --import-realm"
    fi
}

graceful_shutdown() {
    echo "SIGTERM received, shutting down Keycloak gracefully..."

    # Send SIGTERM to Keycloak process
    kill -TERM "$keycloak_pid"
    wait "$keycloak_pid"

    if [ -f "$EXPORT_USERS_SCRIPT" ]; then
        echo "Running export.sh script..."
        bash "$EXPORT_USERS_SCRIPT"
    else
        echo "export.sh script not found."
    fi

    exit 0
}

# Set up trap for SIGTERM
trap 'graceful_shutdown' SIGTERM

# Import from backup directory
if [ -f "$IMPORT_USERS_SCRIPT" ]; then
        bash "$IMPORT_USERS_SCRIPT"
    else
        echo "import.sh script not found."
fi

modify_keycloak_start_cmd

# Start Keycloak in the background and get its PID
echo "Starting Keycloak with command: $KEYCLOAK_START_CMD"
$KEYCLOAK_START_CMD &
keycloak_pid=$!

# Wait for Keycloak process to finish
wait $keycloak_pid
