# Keycloak for CIRG

---

## Steps to use this repository

1. [Install docker](https://docs.docker.com/engine/install/debian/)
2. Add your user to the docker group
   - `sudo usermod -aG docker user_name`
3. Build the container (only needed on the first time)
   - `docker build . -t keycloak_dev`
4. Run the container
   - `docker run --name keycloak_dev -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin -v ./dev-data/init/realm:/opt/keycloak/data/import  -v ./modules/themes:/opt/keycloak/themes keycloak_dev`

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

Run dev server

```
docker build . -t keycloak_dev

docker run --name keycloak_dev -p 127.0.0.1:8080:8080 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
        -v ./dev-data/init/realm:/opt/keycloak/data/import \
        -v ./modules/themes:/opt/keycloak/themes \
        keycloak_dev
```

Use docker-compose to run the server
(no build required)

```
docker compose up -d
```

Use the following command depending on your setup, if docker-compose is in your path

```
docker-compose up -d
```

---

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

### Development Data (dev-data) Directory

- **Purpose**: Contains initial data for starting development containers.
- **Location**: `dev-data/init`
- **Contents**: Includes configuration files, database seeds, etc.

### Backup Directory

- **Location**: Inside the `dev-data` directory.
- **Function**: Stores documentation on export/import variables and serves as a mount point (`/opt/keycloak/backup`) in containers.
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
