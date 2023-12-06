#!/bin/bash

if [ "$KEYCLOAK_BACKUP_RESTORE" != true ]; then
    echo "KEYCLOAK_BACKUP_RESTORE is not set to 'true'. Skipping import."
    exit 0
else
    # Check for JSON files in the backup directory
    if [ -z "$(ls $KEYCLOAK_BACKUP_DIR/*.json 2> /dev/null)" ]; then
        echo "No JSON files found in the backup directory. Skipping import."
        exit 0
    fi

    echo "Importing data from backup directory..."
    kc.sh import --dir "$KEYCLOAK_BACKUP_DIR" --override false

    if [ $? -eq 0 ]; then
        echo "Data backup import successful."
    else
        echo "Data backup import failed."
    fi
fi

