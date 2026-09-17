# Fish shell git commit message workaround with temp file

- **Category:** project_environment_configuration
- **Memory ID:** f378d1e9-e1de-4689-970e-54c98b4d2e2b
- **Keywords:** fish shell, git commit, multiline message, COMMIT_MSG_TMP, repository cleanliness

## Content

When writing complex multiline git commit messages in fish shell, using the -m flag directly can fail due to shell quoting complexity causing timeouts or parsing errors. The reliable workaround is to write the commit message to a temporary file (e.g., .git/COMMIT_MSG_TMP) and use git commit -F <file> instead. This avoids shell escaping issues entirely. Temporary tool scripts (tmp_*.py, __pycache__/) should be intentionally left untracked to keep the repository clean.
