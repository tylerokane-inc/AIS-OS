# Google Workspace CLI (`gws`) Reference

Unified CLI covering Calendar, Gmail, Drive, Sheets, Docs (and more) through
one OAuth setup. Chosen over a dedicated Google Calendar MCP because it's a
CLI, not an MCP — zero tool-schema token cost, called directly via Bash/
PowerShell, same growth-on-demand policy as `references/clickup-api.md`.

Docs root: https://github.com/googleworkspace/cli

## Install

Installed as a standalone binary (NOT via `npm install -g`, which requires
running an unreviewed postinstall script — blocked by this system's script
approval gate). Instead:

1. Downloaded `google-workspace-cli-x86_64-pc-windows-msvc.zip` directly from
   the GitHub Releases page for the target version.
2. Verified its SHA256 against the published `.sha256` file before extracting
   — matches exactly what the npm package's own postinstall script would
   have done, just run manually.
3. Extracted to `%LOCALAPPDATA%\gws-cli\gws.exe`, added that folder to the
   user PATH (permanent — takes effect in new terminal sessions).

Releases: https://github.com/googleworkspace/cli/releases

## Auth

OAuth2, Desktop app credential type. No `gcloud` CLI installed, so used the
manual Cloud Console path instead of `gws auth setup`:

1. Google Cloud Console project + enabled APIs (Calendar, Gmail, Drive,
   Sheets, Docs)
2. OAuth consent screen: External, Tyler's Gmail added as test user
3. OAuth client ID, Desktop app type, downloaded JSON
4. Saved to `C:\Users\User\.config\gws\client_secret.json`
5. `gws auth login --services calendar,gmail,drive,sheets,docs` — deliberately
   NOT `--full` (which also grants Pub/Sub + Cloud Platform scopes, unneeded
   and higher-privilege than anything here calls for)

Credentials are encrypted (AES-256-GCM) and stored via the OS keyring, not a
plaintext file — `gws` manages this itself, nothing for us to maintain.

Authenticated account: `tylerokane.inc@gmail.com`. Scopes granted: drive,
spreadsheets, gmail.modify, calendar, documents, openid, userinfo.email,
userinfo.profile.

Source: https://github.com/googleworkspace/cli (Manual setup / Authentication section)

## Command shape

```
gws <service> <resource> [sub-resource] <method> [flags]
```

Key flags: `--params <JSON>` (query params), `--json <JSON>` (request body),
`--format json|table|yaml|csv`, `--page-all` (auto-paginate NDJSON).

## PowerShell gotcha (important — cost us two failed calls before fixing)

Passing `--params '{"key":"value"}'` from PowerShell to this native exe gets
its inner double-quotes silently stripped by PowerShell's argv encoding,
producing invalid JSON server-side (`key must be a string` error — looks
like an API problem, isn't one). Fix: escape the quotes with backslashes
inside a single-quoted PowerShell string before passing as a variable:

```powershell
$paramsJson = '{\"userId\":\"me\",\"maxResults\":3}'
gws gmail users messages list --params $paramsJson
```

This is a Windows/PowerShell argv-parsing quirk, not a `gws` or Google API
issue — confirmed by reading the actual error body first, per the standing
growth policy in `connections.md`.

## Verified endpoints

### Calendar — today's agenda
```
gws calendar +agenda
```
Convenience command wrapping `calendar.events.list` for today's date range.
Verified live 2026-07-23: returns 0 events (calendar genuinely empty, not an
error).

Source: `gws calendar --help` (run locally; no separate hosted doc page)

### Gmail — list messages
```
gws gmail users messages list --params '{\"userId\":\"me\",\"maxResults\":3}'
```
Verified live 2026-07-23: returned 3 message IDs + thread IDs,
`resultSizeEstimate: 201`.

Source: https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list

## Granted but not yet used (Drive, Sheets, Docs)

Scopes are already authorized (see Auth section) since the OAuth consent
was granted for all five services at once — that part was free. No
endpoints documented here yet per the growth policy: nothing in the current
90-day priorities calls for Drive/Sheets/Docs yet. Sheets is the likely
first of these three to get used (candidate backend for the trading
dashboard or speaking-practice review dashboard side projects). Document the
specific commands here when one of those actually gets built.

## All sources referenced in this file

- https://github.com/googleworkspace/cli
- https://github.com/googleworkspace/cli/releases
- https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list
