#!/bin/bash

source /opt/keycloak/sbin/base.sh

modify_keycloak_start_cmd() {
	if  [ "$KEYCLOAK_DEV_MODE" == true ]; then
		KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD start-dev"
	else
		KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD start"
	fi

	if  [ "$KEYCLOAK_STARTUP_IMPORT" == true ]; then
		KEYCLOAK_START_CMD="$KEYCLOAK_START_CMD --import-realm"
	fi
}

graceful_shutdown() {
	echo  "SIGTERM received, shutting down Keycloak gracefully..."

	pid_file="$KC_PID_FILE"

	if [ -f "$pid_file" ]; then
	    keycloak_pid=$(cat "$pid_file")

	    if ! [[ $keycloak_pid =~ ^[0-9]+$ ]]; then
		echo "Invalid PID: $keycloak_pid"
		exit 1
	    fi

	    kill -TERM "$keycloak_pid"

	    wait "$keycloak_pid"
	else
	    echo "PID file not found: $pid_file"
	    exit 1
	fi


	if  [ -f "$EXPORT_USERS_SCRIPT" ]; then
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
			$EXPORT_USERS_SCRIPT --offline
		else
			echo "KEYCLOAK_BACKUP_ON_SIGTERM is not set to 'true'. Skipping backup."
		fi
	else
		echo "warning: export.sh script not found."
	fi

	exit  0
}

# Set up trap for SIGTERM
trap 'graceful_shutdown' SIGTERM

# Import from backup directory
if [ -f "$IMPORT_USERS_SCRIPT" ]; then
	if      [ "$KEYCLOAK_BACKUP_RESTORE" == true ]; then
		echo      "KEYCLOAK_BACKUP_RESTORE is set to 'true'. Restoring backup."
		$IMPORT_USERS_SCRIPT --offline
	else
		echo "KEYCLOAK_BACKUP_RESTORE is not set to 'true'. Skipping startup backup restore."
	fi
else
	echo "warning: import.sh script not found."
fi

modify_keycloak_start_cmd

# Start Keycloak in the background and get its PID
echo "Starting Keycloak with command: $KEYCLOAK_START_CMD"
$KEYCLOAK_START_CMD &
keycloak_pid=$!
echo $keycloak_pid > "$KC_PID_FILE"
wait $keycloak_pid
