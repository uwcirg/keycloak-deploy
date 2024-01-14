# Keycloak for CIRG

---

## Steps to use this repository

1. [Install docker](https://docs.docker.com/engine/install/debian/)
2. Install docker compose
3. Add your user to the docker group
   - `sudo usermod -aG docker user_name`
4. Run the container from the project root directory
   - `docker compose up -d`

### Testing your app login
You can use this website to test your login functionality
- https://www.keycloak.org/app/#url=http://localhost:8080&realm=cirg&client=app
Or directly via
- http://localhost:8080/realms/cirg/account/#/ (click sign in)

- Accounts
  - Default admin account for [console](http://0.0.0.0:8080/admin/master/console/#/master)
      - User: admin
      - Password: admin
  - Default user account for [user](http://localhost:8080/realms/cirg/account/#/)
    - User: test
    - Password: test

---

## Documentation
 - [Importing and Exporting Realms](https://www.keycloak.org/server/importExport)
 - [Creating a customized and optimized container image](https://www.keycloak.org/server/containers)
 - [Configuring Keycloak for production](https://www.keycloak.org/server/configuration-production)
 - Main doc (log): [Google docs log](https://docs.google.com/document/d/1QVlPUxxprRUYIsNMxpmfGYB9xFuW1vks43U1r8zHCR4/edit?pli=1#heading=h.ygo9dgskih9a)

---

## Requirements
 - Must use standard [quay.io/keycloak/keycloak](https://quay.io/repository/keycloak/keycloak)
 - No build tools/infrastructure outside the repository - besides docker
 - Auto configuration for repository
 - Consider Jars for Providers
 - POC should use CSS, and migrated to SCSS
 - Themes should not have cache off on production

### Important Software Versions

  - Keycloak 22
  - JDK 17
  - Gradle 7

---

## Challenges

- Scattered repositories
- Methodology that could improve to centralize and standardize development/deployment
  - Standard code structure
  - Standard build process
  - Standard deployment
  - Standard env variables, as LOG4J_FORMAT_MSG_NO_LOOKUPS: "true" for CVE-2021-44228
    - Docker compose size reduction as a side effect
  - Standard start scripts, as [docker-entrypoint-override](https://github.com/uwcirg/dcw-environments/blob/main/dev/config/keycloak/docker-entrypoint-override.sh)
- Non-standard scripts outside the codebase repositories, living in the infrastructure repository
- Overuse o freemarker - 35:1
  - Some templates are version specific and this results in harder to maintain codebases
- Freemarker is a heavy language for servers, and the servers are currently overloaded
- Server parameters that should not go live and can be replaced for development by server start command
  -`
      <theme>
      <staticMaxAge>-1</staticMaxAge>
      <cacheThemes>false</cacheThemes>
      <cacheTemplates>false</cacheTemplates>
      </theme>
  `

## Command examples

Run default image for development if needed

```docker run quay.io/keycloak/keycloak start-dev```

Add the docker group to the user if necessary

```sudo usermod -aG docker user_name```

Use docker-compose to run the server
(no build required)

```
docker compose up -d
```

Use the following command depending on your setup, if docker-compose is in your path

```
docker-compose up -d
```

### Import/Export commands
These commands will import and export realms and users, while providing two main modes of operation.

The recommended mode is **offline** in which KC will proceed with a direct approach based on `kc.sh`, assuming KC is stopped.

Along with **KEYCLOAK_BACKUP_ON_SIGTERM** set to true, the *offline* mode will stop KC before proceeding and follow a direct approach with `kc.sh`. 

This recommendation came from the simplicity of this operation, while increasing safety and consistency. Please note
[Importing and Exporting Realms](https://www.keycloak.org/server/importExport).

The import command in the offline mode will not request the server to stop, as it is meant to run before it starts.

The other mode will use the API to import/export data, being more complex in consideration of concerns like cache and data format.

Export users while the container is up and needs to keep running
```
docker compose exec keycloak /opt/keycloak/sbin/export.sh
```

Export users while the container is up/down and needs to stop
```
docker compose exec keycloak /opt/keycloak/sbin/export.sh --offline
```

Import users while the container is up and needs to keep running
```
docker compose exec keycloak /opt/keycloak/sbin/import.sh 
```

Import users while the container is up/down and needs to stop
```
docker compose exec keycloak /opt/keycloak/sbin/import.sh --offline
```

## Environment Variables for data export/import

Three key environment variables control the behavior of the backup and restore processes:

1. **KEYCLOAK_BACKUP_ON_SIGTERM**:
    - This variable, when set to `true`, activates the backup process upon receiving a SIGTERM signal (typically during a container shutdown).
    - If enabled, the script responsible for handling the SIGTERM signal will trigger an export of Keycloak data, storing it in this backup directory.
    - Usage scenario: Primarily used in development environments for preserving data across container restarts or redeployments.

2. **KEYCLOAK_BACKUP_RESTORE**:
    - When set to `true`, this variable enables the restoration of Keycloak data from the backup directory at the startup of the Keycloak container.
    - If enabled, a script will import data from the backup files located in this directory into Keycloak during the container's initialization process.
    - Usage scenario: Useful for initializing Keycloak with pre-existing data, especially after a fresh deployment or in development/testing environments.

3. **KEYCLOAK_STARTUP_IMPORT**:
    - When set to `true`, KC will start with "--import-realm". This will ask KC to import the data from `/opt/keycloak/data/import` during the initial stages of the boot process.
    - This process can import data created by the offline mode provided by the export script or by kc.sh.

All variables default to false, and they can be used if needed, otherwise,
the backup command options should be enough for manual operations.

## Directory structure

This repository is structured to facilitate efficient development workflows, 
with directories designated for specific development purposes. Here's an overview of the key directories:

### Modules Directory

- **Structure**: Adheres to the `<module>/src/<main|test>/<language>` format.
- **Example**: A Java module named `example` would have its main source code in `example/src/main/java`.

### Themes Directory

- **Location**: `modules/themes`
- **Purpose**: Houses theme development files.
- **Structure**: Follows `themes/<theme name>/<theme types>` format.
- **Example**: `modules/themes/cirg/login` contains the login part sources for the `cirg` theme.

### Themes Directory

- **Location**: `lib`
- **Purpose**: Houses additional libraries that might be needed.
- **Structure**: Follows `lib/<library name>` format.
- **Example**: `lib/groovy`.

### Development data Directory

- **Purpose**: Contains initial data for starting development containers.
- **Location**: `data/import`
- **Contents**: Includes configuration files, database seeds, etc.

### Backup Directory

- **Purpose**: Stores backup data created for export/import routines and serves as a mount point for (`/opt/keycloak/backup`).
- **Location**: `data/backup`
- **Configuration**: Refer to the example below for setting up the backup directory in Docker Compose.

```yaml
# Docker Compose setup example for the backup directory
volumes:
  backup:
    # Configuration details here
```

---

## Important locations

### Infrastructure locations
- [uranium](https://gitlab.cirg.washington.edu/infrastructure/puppet-admins/puppet-6-server/-/blob/development/data/nodes/uranium.cirg.washington.edu.yaml)
    - Future - Keycloak dev (keycloak-dev.cirg.washington.edu)
    - Future - Keycloak test (keycloak-test.cirg.washington.edu)
    - Keycloak alpha (keycloak-alpha.cirg.washington.edu)

- [protactinium](https://gitlab.cirg.washington.edu/infrastructure/puppet-admins/puppet-6-server/-/blob/development/data/nodes/uranium.cirg.washington.edu.yaml)
  - Keycloak production (keycloak.cirg.washington.edu)
  - Keycloak dev (keycloak-dev.cirg.washington.edu) 
  - Keycloak test (keycloak-test.cirg.washington.edu)

### Infrastructure codebases

### Providers
- [providers](https://gitlab.cirg.washington.edu/infrastructure/puppet-admins/puppet-6-server/-/tree/development/site/keycloak_server/files/Debian/_default_/srv/www/keycloak/providers)

### Tools and scripts
- [sbin](https://gitlab.cirg.washington.edu/infrastructure/puppet-admins/puppet-6-server/-/tree/development/site/keycloak_server/files/Debian/_default_/usr/local/sbin)

### Puppet config (templates)
- [srv](https://gitlab.cirg.washington.edu/infrastructure/puppet-admins/puppet-6-server/-/tree/development/site/keycloak_server/templates/Debian/_default_/srv/www/keycloak)

---

### Related repositories
Gitlab - from 2020 - deprecated
Private repo
- [Keyclock group](https://gitlab.cirg.washington.edu/keycloak)
  - [Keyclock themes](https://gitlab.cirg.washington.edu/keycloak/themes)
    - [cosri](https://gitlab.cirg.washington.edu/keycloak/themes/cosri)

Github - from 2022
Public repo
- [dcw-environments](https://github.com/uwcirg/dcw-environments)
  - [dcw-keycloak-theme](https://github.com/uwcirg/dcw-keycloak-theme)
  - [server config](https://github.com/uwcirg/dcw-environments/tree/main/dev/config/keycloak)
  - [compose](https://github.com/uwcirg/dcw-environments/blob/main/dev/docker-compose.yaml)
- [helloworld-environments](https://github.com/uwcirg/helloworld-environments)
  - The "dcw" and "cosri" systems were intended to extend this.

Github - from 2024
Public repo
- [ltt-environments](https://github.com/uwcirg/ltt-environments/blob/main/dev/docker-compose.yaml)