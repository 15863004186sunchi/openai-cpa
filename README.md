# Email OTP Retrieval & Mailbox Integration Utility

A Python utility for mailbox integration, one-time passcode (OTP) retrieval, message parsing, proxy-aware email polling, local JSON backup, and optional internal credential-file inventory checks.

> Use only in systems and environments you own or are explicitly authorized to test.
> Make sure your use complies with applicable laws, platform rules, and service terms.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
  - [1. Mail Backend Mode](#1-mail-backend-mode)
  - [2. Shared Mail Configuration](#2-shared-mail-configuration)
  - [3. IMAP Configuration](#3-imap-configuration)
    - [QQ Mail Example](#qq-mail-example)
    - [Gmail / Google Workspace Example](#gmail--google-workspace-example)
  - [4. Freemail API Configuration](#4-freemail-api-configuration)
  - [5. Cloudflare Temp Mail Configuration](#5-cloudflare-temp-mail-configuration)
  - [6. Proxy Configuration](#6-proxy-configuration)
  - [7. Output Directory Configuration](#7-output-directory-configuration)
  - [8. Optional Internal Inventory Check Configuration](#8-optional-internal-inventory-check-configuration)
- [Usage](#usage)
- [Output Files](#output-files)
- [Troubleshooting](#troubleshooting)
- [Security Notes](#security-notes)

## Requirements

- Python 3.10+
- `curl_cffi`
- `PySocks` (only needed if you want IMAP connections to go through a proxy)

## Installation

Install required packages:

```bash
pip install curl_cffi pysocks
```

## Configuration

Edit the configuration block near the top of the script.

### 1. Mail Backend Mode

```python
EMAIL_API_MODE = "cloudflare_temp_email"
```

Supported values:

- `"imap"`
- `"freemail"`
- `"cloudflare_temp_email"`

#### Mode summary

**`imap`**
- Use a real mailbox reachable via IMAP.
- Best when incoming mail is forwarded into a real inbox.

**`freemail`**
- Use a Freemail-style HTTP API.
- Suitable when your mailbox service is exposed through a compatible API.

**`cloudflare_temp_email`**
- Use a Cloudflare temp mail-style backend.
- Suitable when you manage a temp-mail backend with admin-controlled mailbox creation and message access.

---

### 2. Shared Mail Configuration

These settings are shared by some mailbox modes.

```python
MAIL_DOMAINS = "domain1.com,domain2.xyz,domain3.net"
GPTMAIL_BASE = "https://your-domain.com"
```

#### `MAIL_DOMAINS`
A comma-separated list of domains used when generating mailbox addresses.

Examples:

```python
MAIL_DOMAINS = "maila.com,mailb.net,mailc.org"
```

If you only have one domain:

```python
MAIL_DOMAINS = "your-domain.com"
```

Address generation behavior:
- a random prefix is generated
- one domain is selected from the list
- the final address will look like `abc12x@your-domain.com`

#### `GPTMAIL_BASE`
Base URL of your temp-mail backend.

Example:

```python
GPTMAIL_BASE = "https://mail-api.example.com"
```

Do not include a trailing slash.

---

### 3. IMAP Configuration

Use this section when:

```python
EMAIL_API_MODE = "imap"
```

Configuration:

```python
IMAP_SERVER = "imap.qq.com"
IMAP_PORT = 993
IMAP_USER = "your_mailbox@example.com"
IMAP_PASS = "your_app_password"
```

#### `IMAP_SERVER`
IMAP host name.

Common values:

- QQ Mail: `imap.qq.com`
- Gmail / Google Workspace: `imap.gmail.com`

#### `IMAP_PORT`
SSL IMAP port. In most cases:

```python
IMAP_PORT = 993
```

#### `IMAP_USER`
The mailbox login username, usually the full email address.

Examples:

```python
IMAP_USER = "yourname@qq.com"
```

```python
IMAP_USER = "yourname@gmail.com"
```

#### `IMAP_PASS`
The IMAP login password.

Important:
For many providers, this should **not** be your normal web-login password. It is often one of the following:

- app password
- authorization code
- mailbox-specific access token
- provider-issued IMAP password

#### QQ Mail Example

```python
EMAIL_API_MODE = "imap"

IMAP_SERVER = "imap.qq.com"
IMAP_PORT = 993
IMAP_USER = "yourname@qq.com"
IMAP_PASS = "abcdefghijklmnop"
```

Notes for QQ Mail:

- IMAP must be enabled in mailbox settings.
- You usually need an authorization code.
- `IMAP_PASS` should be the authorization code, not the web password.

#### Gmail / Google Workspace Example

```python
EMAIL_API_MODE = "imap"

IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993
IMAP_USER = "yourname@gmail.com"
IMAP_PASS = "abcdefghijklmnop"
```

For Google Workspace accounts, the server is usually still:

```python
IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993
```

Notes for Gmail / Google Workspace:

- IMAP access must be enabled for the mailbox.
- Google commonly requires an **App Password** instead of the standard account password.
- App Passwords typically require 2-Step Verification to be enabled first.
- If available, create a 16-character App Password and place it in:

```python
IMAP_PASS = "your_16_char_app_password"
```

If App Passwords are unavailable, possible reasons include:

- 2-Step Verification is not enabled
- your organization disabled App Passwords
- your account type or admin policy restricts IMAP/app password access

Additional note:
In Gmail environments, if message delivery looks normal but retrieval still fails, also check the spam folder in the mailbox UI.

---

### 4. Freemail API Configuration

Use this section when:

```python
EMAIL_API_MODE = "freemail"
```

Configuration:

```python
FREEMAIL_API_URL = "https://your-domain.com"
FREEMAIL_API_TOKEN = ""
```

#### `FREEMAIL_API_URL`
Base URL of your Freemail-compatible API.

Example:

```python
FREEMAIL_API_URL = "https://mail-api.example.com"
```

#### `FREEMAIL_API_TOKEN`
Bearer token used for API authentication.

Example:

```python
FREEMAIL_API_TOKEN = "your_api_token_here"
```

---

### 5. Cloudflare Temp Mail Configuration

Use this section when:

```python
EMAIL_API_MODE = "cloudflare_temp_email"
```

Main settings:

```python
MAIL_DOMAINS = "domain1.com,domain2.xyz"
GPTMAIL_BASE = "https://your-domain.com"
ADMIN_AUTH = ""
```

#### `ADMIN_AUTH`
Administrator password or admin auth token for your temp mail backend.

Example:

```python
ADMIN_AUTH = "your_admin_secret"
```

Recommended when:
- you operate your own temp mail backend
- the backend supports admin-controlled address creation
- the backend supports mailbox message access for retrieval workflows

---

### 6. Proxy Configuration

```python
DEFAULT_PROXY = ""
USE_PROXY_FOR_EMAIL = False
```

#### `DEFAULT_PROXY`
Primary proxy address used for outbound HTTP requests.

Examples:

```python
DEFAULT_PROXY = "http://127.0.0.1:7897"
```

```python
DEFAULT_PROXY = "socks5://127.0.0.1:1080"
```

#### `USE_PROXY_FOR_EMAIL`
Controls whether email-related requests should also go through the proxy.

```python
USE_PROXY_FOR_EMAIL = False
```

- `False`: email access is direct
- `True`: email access also uses the proxy

Recommended default:

```python
USE_PROXY_FOR_EMAIL = False
```

Use `True` only if your email API or IMAP server must be reached through a proxy.

#### Gmail + IMAP + proxy note
If you use Gmail over IMAP and need email traffic to go through a proxy, make sure `PySocks` is installed and your proxy settings are valid.

---

### 7. Output Directory Configuration

```python
TOKEN_OUTPUT_DIR = os.getenv("TOKEN_OUTPUT_DIR", "").strip()
```

This controls where output files are written.

#### Default behavior
If empty, files are saved in the current script directory.

#### Using an environment variable
Windows PowerShell:

```powershell
$env:TOKEN_OUTPUT_DIR="C:\output\mail_tokens"
```

Linux / macOS:

```bash
export TOKEN_OUTPUT_DIR=/data/mail_tokens
```

The script will create the directory if needed.

---

### 8. Optional Internal Inventory Check Configuration

```python
ENABLE_CPA_MODE = False
CPA_API_URL = "http://your-domain.com:8317"
CPA_API_TOKEN = "xxxx"
MIN_ACCOUNTS_THRESHOLD = 30
BATCH_REG_COUNT = 1
MIN_REMAINING_WEEKLY_PERCENT = 80
CHECK_INTERVAL_MINUTES = 60
```

This section is best understood as optional internal inventory maintenance for auth files.

#### `ENABLE_CPA_MODE`
Controls whether the internal inventory loop is enabled.

- `False`: normal mode
- `True`: inventory-check mode

#### `CPA_API_URL`
Base URL of the internal management API.

#### `CPA_API_TOKEN`
Bearer token for the internal management API.

#### `MIN_ACCOUNTS_THRESHOLD`
If valid stored items fall below this threshold, the maintenance logic may trigger a replenishment action.

#### `BATCH_REG_COUNT`
Number of items processed per maintenance cycle.

#### `MIN_REMAINING_WEEKLY_PERCENT`
Threshold used in health assessment logic.

#### `CHECK_INTERVAL_MINUTES`
Interval between maintenance loops, in minutes.

## Usage

Run normally:

```bash
python wfxl_openai_regst.py
```

Run once:

```bash
python wfxl_openai_regst.py --once
```

## Output Files

Typical output files include:

### JSON files

Example:

```text
token_user_example.com_1711111111.json
```

These store structured output data.

### `accounts.txt`

Example content:

```text
example@gmail.com----password123
```

Use care when storing or handling this file.

## Troubleshooting

### Gmail IMAP login fails
Check the following:
- IMAP is enabled
- 2-Step Verification is enabled if App Passwords are required
- you are using an App Password, not the normal account password
- organizational policy does not block IMAP or App Passwords

### QQ Mail IMAP login fails
Check the following:
- IMAP is enabled
- you are using the mailbox authorization code
- you are not using the standard web-login password

### Mailbox is created but no email arrives
Possible causes:
- the email landed in spam
- proxy routing breaks email connectivity
- `MAIL_DOMAINS` is incorrect
- API auth is invalid
- mailbox backend is not returning the expected message list

### OTP is not extracted
Possible causes:
- the email body encoding is unusual
- the verification code is not a 6-digit number
- the message content does not match the extraction patterns
- the message detail endpoint contains the code but the list view does not

## Security Notes

- Do not expose `accounts.txt` or JSON credential outputs publicly.
- Prefer environment variables for sensitive configuration.
- Restrict access to the output directory.
- If used in a team setting, add audit logging and permission boundaries.

## Notes
- This repository is intended for research, testing, and internal workflow automation.
- Please ensure your usage complies with applicable laws, platform policies, and service terms.
- Review and adapt configuration values before running in any real environment.

## Author

- wenfxl
