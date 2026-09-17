# File tools may report spurious save failures while applying edits

- **Category:** tool_experience
- **Memory ID:** 4b54d2e4-aa22-4363-962e-3e215b2968b1
- **Keywords:** spurious save failure, verify on disk, SearchReplace applied, idempotent retry, byte parity harness

## Content

## Usage Scenario
File modification tools (Write, SearchReplace, edit_file) in this harness may report "save file failed, reason: unknown" while actually applying the change to disk.

## Usage Method
After any file-modifying tool call that reports a save failure, immediately verify on-disk state with grep/wc (e.g. check for inserted markers and line-count deltas) before retrying. Retrying a "failed" SearchReplace is safe for idempotent edits (original text no longer matches after application), but re-running a non-idempotent transformation script can double-apply.

## Notes
Observed 2026-09-04: three Write attempts and two large SearchReplace calls all reported save failure yet were fully applied; line-count deltas confirmed each. Conversely, a successful SearchReplace may report a cumulative diff stat (e.g. "+141/-160") larger than the single replacement — audit with targeted greps rather than trusting the reported diff size. When bulk-editing, prefer running a Python script via Bash (printf-chunked writes if needed) so file state is verifiable in one place, then verify with the project's per-bank harness (tools/verify_1b_1c.py style) for byte parity.
