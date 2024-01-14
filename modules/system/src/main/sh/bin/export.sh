#!/bin/bash

source /opt/keycloak/sbin/base.sh

ONLINE=true

show_help() {
	echo  "Usage to export users: ${0##*/} [OPTIONS]"
	echo
	echo  "Options:"
	echo  "  --offline   Run the script in offline mode."
	echo  "  --help      Display this help message."
}

online_export() {
	kcadm.sh config credentials --server http://localhost:8080 --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

	echo  "Exporting all realms and users to $KEYCLOAK_BACKUP_DIR"

	realms=$(kcadm.sh get realms | grep -o '"realm" *: *"[^"]*' | grep -o '[^"]*$')

	for realm in $realms; do
	    # Export realm configuration
	    realm_file="$KEYCLOAK_BACKUP_DIR/${realm}-realm.json"
	    kcadm.sh get realms/$realm > "$realm_file"
	    echo "Exported realm configuration to $realm_file"

	    # Export users for the realm
	    users_file="$KEYCLOAK_BACKUP_DIR/${realm}-users.json"
	    kcadm.sh get users -r "$realm" > "$users_file"
	    echo "Exported users for realm $realm to $users_file"
        done

	if  [ -f "$BACKUP_FILE_REALMS_PATH" ]; then
		echo     "Realm export successful. File created at: $BACKUP_FILE_REALMS_PATH"
	else
		echo     "Realm Export failed. File not found: $BACKUP_FILE_REALMS_PATH"
	fi
}

offline_export() {
	kc.sh  export --dir "$KEYCLOAK_BACKUP_DIR" --file "$BACKUP_FILE_REALMS_PATH"

	if  [ -f "$BACKUP_FILE_REALMS_PATH" ]; then
		echo "Export successful. File created at: $BACKUP_FILE_REALMS_PATH"
	else
		echo "Export failed. File not found: $BACKUP_FILE_REALMS_PATH"
	fi
}

check_requirements() {
	local  missing_requirements=false

	if  [ "$ONLINE" = true ]; then
		if     [ -z "$KCADMIN" ]; then
			echo        "warning: KCADMIN variable is not set."
			missing_requirements=true
		fi

		if     [ -z "$KEYCLOAK_ADMIN" ]; then
			echo        "warning: KEYCLOAK_ADMIN variable is not set."
			missing_requirements=true
		fi

		if     [ -z "$KEYCLOAK_ADMIN_PASSWORD" ]; then
			echo        "warning: KEYCLOAK_ADMIN_PASSWORD variable is not set."
			missing_requirements=true
		fi
	fi

	if  [ -z "$KEYCLOAK_BACKUP_DIR" ]; then
		echo     "warning: KEYCLOAK_BACKUP_DIR variable is not set."
		missing_requirements=true
	elif  [ ! -d "$KEYCLOAK_BACKUP_DIR" ]; then
		echo     "warning: Backup directory ($KEYCLOAK_BACKUP_DIR) does not exist."
		missing_requirements=true
	elif  [ ! -w "$KEYCLOAK_BACKUP_DIR" ]; then
		echo     "warning: No write permission for the backup directory ($KEYCLOAK_BACKUP_DIR)."
		missing_requirements=true
	fi

	if  [ "$missing_requirements" = true ]; then
		echo     "One or more requirements are missing. Exiting script."
		exit     1
	fi
}

while [[ "$#" -gt 0 ]]; do
	case "$1" in
		--offline)     ONLINE=false ;;
		--help)
			show_help
			exit                       0
			;;
		*)
			echo       "Unknown option: $1" >&2
			show_help
			exit                                                 1
			;;
	esac
	shift
done

mkdir -p "$KEYCLOAK_BACKUP_DIR"

check_requirements

if [ "$ONLINE" = true ]; then
	online_export
else
	offline_export
fi
