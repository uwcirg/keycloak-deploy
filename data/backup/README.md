# Keycloak Backup Directory

## Overview

This directory is part of a Keycloak deployment configured for automated backup and restore functionality in a Dockerized environment. It plays a crucial role in managing backups of Keycloak data, specifically pertaining to user data and realm configurations.

## Environment Variables

Two key environment variables control the behavior of the backup and restore processes:

1. **KEYCLOAK_BACKUP_ON_SIGTERM**:
    - This variable, when set to `true`, activates the backup process upon receiving a SIGTERM signal (typically during a container shutdown).
    - If enabled, the script responsible for handling the SIGTERM signal will trigger an export of Keycloak data, storing it in this backup directory.
    - Usage scenario: Primarily used in development environments for preserving data across container restarts or redeployments.

2. **KEYCLOAK_BACKUP_RESTORE**:
    - When set to `true`, this variable enables the restoration of Keycloak data from the backup directory at the startup of the Keycloak container.
    - If enabled, a script will import data from the backup files located in this directory into Keycloak during the container's initialization process.
    - Usage scenario: Useful for initializing Keycloak with pre-existing data, especially after a fresh deployment or in development/testing environments.

## Directory Structure

- The backup directory contains JSON files representing exported data from Keycloak. These files are generated by the backup script and are named according to the date and time of the backup.

## Important Notes

- **Security**: As the backup files may contain sensitive data, ensure this directory is secured appropriately.
- **Backup Frequency**: The backups are triggered based on the container's lifecycle events and environment variable configurations.
- **Data Integrity**: Ensure that backups are consistent and complete, especially when used for data restoration.
- **Environment Specific**: The use of these environment variables and the backup/restore functionality should be tailored to the specific requirements of your environment.

## Conclusion

This backup directory, in conjunction with `KEYCLOAK_BACKUP_ON_SIGTERM` and `KEYCLOAK_BACKUP_RESTORE`, provides a mechanism for managing Keycloak data in a flexible and automated manner, suitable for development and testing environments. For production environments, consider more robust and scalable backup solutions, such as database-level backups.