# Git HTTPS Authentication Configuration for GitHub

- **Category:** project_scm_configuration
- **Memory ID:** 3b1b1d27-bea0-424a-9536-2523cec9c697
- **Keywords:** Git authentication, personal access token, credential helper, HTTPS

## Content

Git authentication for GitHub uses HTTPS with personal access tokens. Supported credential management methods include:
- `store`: stores credentials in plaintext at `~/.git-credentials`
- `cache`: caches credentials in memory
When using direct URLs, format as `https://USERNAME:TOKEN@github.com/USERNAME/REPO.git`
Credentials can be updated via `git credential reject` or by editing the credentials file directly.
