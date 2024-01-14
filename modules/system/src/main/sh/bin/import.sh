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

    kcadm.sh config credentials --server http://localhost:8080 --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

    echo "Importing all realms and users from $KEYCLOAK_BACKUP_DIR"

    for realm_file in "$KEYCLOAK_BACKUP_DIR"/*-realm.json; do
        [ -e "$realm_file" ] || continue  # skip if no files found

        realm=$(basename "$realm_file" -realm.json)

        echo "Importing realm from $realm_file"
        kcadm.sh update "realms/$realm" -f "$realm_file"

        users_file="$KEYCLOAK_BACKUP_DIR/${realm}-users.json"
        if [ -f "$users_file" ]; then
	    while IFS= read -r user; do
		username=$(echo "$user" | grep -o '"username":"[^"]*' | cut -d '"' -f 4)
		user_id=$(echo "$user" | grep -o '"id":"[^"]*' | cut -d '"' -f 4)

		if [ -n "$user_id" ]; then
		    echo "Updating user $username in realm $realm"
		    echo "$user" | kcadm.sh update users/$user_id -r "$realm" -f -
		else
		    echo "Creating user $username in realm $realm"
		    echo "$user" | kcadm.sh create users -r "$realm" -f -
		fi
	    done < <(/opt/keycloak/sbin/groovy/users/parseUsers.groovy "$users_file")
        else
            echo "User file for realm $realm not found: $users_file"
        fi
    done
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
