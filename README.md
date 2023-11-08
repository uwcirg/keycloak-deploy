# Keycloak for CIRG

---

## Steps to use this repository

1. [Install docker](https://docs.docker.com/engine/install/debian/)
2. Add your user to the docker group
   - `sudo usermod -aG docker user_name`
3. Build the container (only needed on the first time)
   - `docker build . -t keycloak_dev`
4. Run the container
   - `docker run --name keycloak_dev -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin -v ./dev-data/realm:/opt/keycloak/data/import  -v ./themes:/opt/keycloak/themes keycloak_dev`

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

## Repository structure

If you are working on a theme, please focus on the `themes` directory.

Your static files will be on `themes/theme_name/theme_type/resources`

For instance if your theme is called `cirg` and you are working on a theme for the login page,
The directory will be `themes/cirg/login/resources`

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

docker run --name keycloak_dev -p 8080:8080 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
        -v ./dev-data/realm:/opt/keycloak/data/import \
        -v ./themes:/opt/keycloak/themes \
        keycloak_dev
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
Gitlab - from 2020
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
