# CIRG Parent Theme for Keycloak

The `cirg` theme is a base parent theme for Keycloak designed to provide a foundational structure for creating customized experiences. It serves as a reusable and extendable template that includes common styles, templates, scripts, and frontend libraries (e.g., Bootstrap and FontAwesome). Future projects can extend this theme to implement custom branding, layout, and functionality while maintaining a consistent core experience.

## Goals

- **Reusability**: Provide a common base theme that can be extended for multiple projects.
- **Customization**: Allow child themes to override and extend specific templates, styles, and resources.
- **Consistency**: Ensure a consistent user experience across all extended themes by using shared resources.

## Directory Structure

The `cirg` theme is organized with a clear directory structure that follows Keycloak's theme conventions:

```plaintext
cirg/                      # Parent theme directory
├── login/                 # Login theme folder for cirg
│   ├── theme.properties   # Theme properties file
│   ├── messages/          # Folder for message bundles (i18n)
│   │   └── messages_en.properties  # Example message bundle
│   ├── resources/         # Static resources (CSS, JS, images)
│   │   ├── css/           # Custom CSS for the login theme
│   │   ├── js/            # Custom JS for the login theme
│   │   ├── img/           # Images used in the login theme
│   │   └── lib/           # Frontend libraries (Bootstrap, FontAwesome, etc.)
│   │       ├── bootstrap/ # Bootstrap library files
│   │       └── fontawesome/ # FontAwesome library files
│   └── templates/         # HTML templates for the login theme
│       ├── login.ftl      # Example FreeMarker template for login
│       └── other_template.ftl  # Another template
└── other_subthemes/       # Placeholder for potential other subthemes under cirg
```

## Extending the CIRG Theme for Future Projects

To create a new theme that extends the `cirg` parent theme, follow these steps:

1. **Create a New Theme Directory**:
    - Create a new folder under the `themes` directory (e.g., `my-new-theme`).

2. **Set Up the `theme.properties` File**:
    - In the `my-new-theme/login` directory, create a `theme.properties` file with the following content:
      ```properties
      parent=cirg
      internationalizationEnabled=true
      ```

3. **Override or Extend Resources**:
    - Add custom CSS, JavaScript, images, or templates in the `my-new-theme/login/resources` or `my-new-theme/login/templates` directories.
    - Only override files that need customization; others will inherit from the `cirg` theme.

4. **Deploy the Theme to Keycloak**:
    - Copy the new theme folder to `<keycloak-installation-directory>/themes`.
    - Restart the Keycloak server to apply the changes.

5. **Configure the Realm to Use the New Theme**:
    - In the Keycloak Admin Console, navigate to **Realm Settings > Themes** and select your new theme under **Login Theme**.
