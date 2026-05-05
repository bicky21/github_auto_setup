param (
    [Parameter(Mandatory=$true)]
    [string]$repoName,

    [Parameter(Mandatory=$true)]
    [string]$username
)

# ==============================
# VALIDATION
# ==============================
if (-not $repoName.Trim()) { throw "repoName cannot be empty" }
if (-not $username.Trim()) { throw "username cannot be empty" }

# ==============================
# LOAD TOKEN SECURELY
# ==============================
$token = $env:GITHUB_TOKEN
if (-not $token) {
    throw "GITHUB_TOKEN environment variable is not set"
}

Write-Host "Starting setup..."
Write-Host "Repo: $repoName | User: $username"

# ==============================
# CREATE GITHUB REPO
# ==============================
Write-Host "Creating GitHub repository..."

$body = @{
    name = $repoName
    private = $false
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://api.github.com/user/repos" `
        -Headers @{
            Authorization = "token $token"
            "User-Agent"  = "PowerShell"
            Accept        = "application/vnd.github+json"
        } `
        -Body $body

    Write-Host "Repository created successfully."
}
catch {
    Write-Host "GitHub API Error:"
    Write-Host $_.Exception.Message

    # If repo already exists, continue instead of failing hard
    if ($_.Exception.Message -match "name already exists") {
        Write-Host "Repo already exists. Continuing..."
    } else {
        exit 1
    }
}

# ==============================
# INITIALIZE LOCAL GIT
# ==============================
if (-not (Test-Path ".git")) {
    git init
    Write-Host "Initialized empty Git repository."
}

# ==============================
# ENSURE GIT IDENTITY
# ==============================
$gitName = git config user.name
$gitEmail = git config user.email

if (-not $gitName) {
    git config --global user.name "Bicky"
}

if (-not $gitEmail) {
    git config --global user.email "your-email@example.com"
}

# ==============================
# CREATE INITIAL COMMIT (SAFE)
# ==============================
if (git status --porcelain) {
    git add .
    git commit -m "Initial commit"
    Write-Host "Initial commit created."
} else {
    Write-Host "No changes to commit."
}

# ==============================
# SET MAIN BRANCH
# ==============================
git branch -M main

# ==============================
# CONFIGURE REMOTE (IDEMPOTENT)
# ==============================
$remoteUrl = "https://github.com/$username/$repoName.git"

git remote remove origin 2>$null
git remote add origin $remoteUrl

Write-Host "Remote set to: $remoteUrl"

# ==============================
# PUSH TO GITHUB
# ==============================
Write-Host "Pushing to GitHub..."

try {
    git push -u origin main
    Write-Host "Push successful."
}
catch {
    Write-Host "Push failed:"
    Write-Host $_
    exit 1
}

# ==============================
# DONE
# ==============================
Write-Host "Done!"
Write-Host "Repo URL: https://github.com/$username/$repoName"