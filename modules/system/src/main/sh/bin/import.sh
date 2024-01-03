#!/bin/bash

source /opt/keycloak/sbin/base.sh

ONLINE=true

show_help() {
	echo  "Usage to import users: ${0##*/} [OPTIONS]"
	echo
	echo  "Options:"
	echo  "  --offline   Run the script in offline mode."
	echo  "  --help      Display this help message."
}

online_import() {
	if  [ -z "$KEYCLOAK_BACKUP_DIR" ]; then
		echo     "warning: No import directory specified. Set the KEYCLOAK_BACKUP_DIR variable to the path of the directory to import."
		return     1
	fi

	if  [ ! -d "$KEYCLOAK_BACKUP_DIR" ]; then
		echo     "warning: Import directory ($KEYCLOAK_BACKUP_DIR) not found."
		return     1
	fi

	kcadm.sh  config credentials --server http://localhost:8080/auth --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

	echo  "Importing data from directory $KEYCLOAK_BACKUP_DIR"
	kcadm.sh  import --dir "$KEYCLOAK_BACKUP_DIR"

	if  [ $? -eq 0 ]; then
		echo     "Data import from directory successful."
	else
		echo     "Data import from directory failed."
	fi
}

offline_import() {
	if  [ -z "$(ls $KEYCLOAK_BACKUP_DIR/*.json 2>/dev/null)"  ]; then
		echo "No JSON files found in the backup directory. Skipping import."
		exit 0
	fi

	echo  "Importing data from backup directory..."
	kc.sh  import --dir "$KEYCLOAK_BACKUP_DIR" --override false

	if  [ $? -eq 0 ]; then
		echo "Data backup import successful."
	else
		echo "Data backup import failed."
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
	elif  [ ! -r "$KEYCLOAK_BACKUP_DIR" ]; then
		echo "warning: No read permission for the backup directory ($KEYCLOAK_BACKUP_DIR)."
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

check_requirements

if [ "$ONLINE" = true ]; then
	online_import
else
	offline_import
fi
