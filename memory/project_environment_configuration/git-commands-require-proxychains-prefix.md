# Git commands require proxychains prefix

- **Category:** project_environment_configuration
- **Memory ID:** 80b0077c-020b-44f5-9d2a-7c9ae7e16ac5
- **Keywords:** git, proxy, proxychains, network, commands
- **Usage scenarios:**
  - Running git clone
  - Running git pull/push/fetch
  - Any git remote operation

## Content

When executing git commands (clone, pull, push, fetch, etc.), prepend "proxychains -q" to enable proxy routing. Example: `proxychains -q git pull origin main`.
