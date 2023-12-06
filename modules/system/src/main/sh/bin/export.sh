#!/bin/bash

EXPORT_FILE="keycloak-export.json"
FULL_EXPORT_PATH="$KEYCLOAK_BACKUP_DIR/$EXPORT_FILE"

# KEYCLOAK_BACKUP_ON_SIGTERM is an custom environment variable designed for use in Dockerized Keycloak environments,
# primarily for development purposes. It controls whether a script exports user data when a SIGTERM signal is received,
# ensuring data persistence across restarts. However, this approach is not recommended for production due to scalability
# and maintainability limitations.
#
# In production, database backups are preferred for their robustness and efficiency.
# KEYCLOAK_BACKUP_ON_SIGTERM can serve as a transitional solution before adopting a database backup strategy,
# especially in setups not yet equipped with comprehensive database backup systems.
if [ "$KEYCLOAK_BACKUP_ON_SIGTERM" == true ]; then
    echo "KEYCLOAK_BACKUP_ON_SIGTERM is set to 'true'. Proceeding with backup."

    # Create the backup directory if it doesn't exist
    mkdir -p "$KEYCLOAK_BACKUP_DIR"

    # Export all realms
    kc.sh export --dir "$KEYCLOAK_BACKUP_DIR" --file "$FULL_EXPORT_PATH"

    # Check if export was successful
    if [ -f "$FULL_EXPORT_PATH" ]; then
        echo "Export successful. File created at: $FULL_EXPORT_PATH"
    else
        echo "Export failed. File not found: $FULL_EXPORT_PATH"
    fi
else
    echo "KEYCLOAK_BACKUP_ON_SIGTERM is not set to 'true'. Skipping backup."
fi
