$ErrorActionPreference = "Stop"

# Always run from this script's folder (repo root).
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repo

# Stage only HTML files.
git add -- "*.html"

# Check if any HTML file is staged.
$stagedHtml = git diff --cached --name-only -- "*.html"
if (-not $stagedHtml) {
    Write-Host "Nenhuma alteracao .html para commit."
    exit 0
}

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if (-not $branch) {
    Write-Error "Nao foi possivel identificar a branch atual."
    exit 1
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$files = ($stagedHtml -split "`r?`n" | Where-Object { $_ -and $_.Trim() -ne "" } | ForEach-Object { $_.Trim() })
$filesText = ($files -join ", ")

# Keep commit subject reasonably short.
if ($filesText.Length -gt 140) {
    $preview = ($files | Select-Object -First 3) -join ", "
    $filesText = "{0} arquivo(s): {1}, ..." -f $files.Count, $preview
}

$message = "auto: html [$filesText] $timestamp"
git commit -m $message
git push origin $branch

Write-Host "Commit e push concluidos para arquivos .html na branch '$branch'."
