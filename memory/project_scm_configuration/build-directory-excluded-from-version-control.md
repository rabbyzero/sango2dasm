# Build directory excluded from version control

- **Category:** project_scm_configuration
- **Memory ID:** 30456f58-c2cc-47c4-9c9f-8cd8f6fd3c04
- **Keywords:** build directory, .gitignore, version control
- **Usage scenarios:**
  - Setting up a new development environment and configuring git ignore rules
  - Adding new build artifacts and ensuring they are not accidentally committed
  - Reviewing pull requests for unintended file additions

## Content

The project's build output directory `build/` is added to `.gitignore` to prevent build artifacts from being tracked in version control. Only source code and configuration files should be committed.
