# GitHub Secure Repo Setup Script (PowerShell)

Automates secure creation and initialization of GitHub repositories using PowerShell and GitHub API.

---

## Features

* Creates GitHub repository via API
* Initializes local Git repository
* Adds initial commit safely
* Configures remote origin
* Pushes to `main` branch
* Uses secure token via environment variable

---

## Requirements

* PowerShell 5+
* Git installed
* GitHub Personal Access Token (PAT)

---

## Setup

### 1. Set GitHub Token

```powershell
$env:GITHUB_TOKEN="your_token_here"
```

---

### 2. Run Script

```powershell
.\scripts\git_secure_setup.ps1 -repoName "your-repo" -username "your-username"
```

---

## Parameters

| Parameter | Description                   |
| --------- | ----------------------------- |
| repoName  | Name of the GitHub repository |
| username  | GitHub username               |

---

## Security Notes

* Never commit `.env` files
* Always use environment variables for tokens
* Rotate tokens if exposed

---

## Example

```powershell
.\scripts\git_secure_setup.ps1 -repoName "my-project" -username "bicky21"
```

---

## License

MIT (optional)
