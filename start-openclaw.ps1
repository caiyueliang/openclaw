# OpenClaw Docker Deployment Script for Windows
# Using domestic mirror for faster builds

$ErrorActionPreference = "Stop"

Write-Host "OpenClaw Docker Deployment Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Check Docker
Write-Host "Checking Docker status..." -ForegroundColor Yellow
try {
    $dockerVersion = docker version --format '{{.Server.Version}}' 2>$null
    Write-Host "Docker is installed (version: $dockerVersion)" -ForegroundColor Green
} catch {
    Write-Host "Docker is not installed or not running" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and ensure it's running" -ForegroundColor Yellow
    exit 1
}

# Set environment variables
$env:OPENCLAW_IMAGE = "openclaw:local"
$env:OPENCLAW_CONFIG_DIR = "$env:USERPROFILE\.openclaw"
$env:OPENCLAW_WORKSPACE_DIR = "$env:USERPROFILE\.openclaw\workspace"
$env:OPENCLAW_GATEWAY_PORT = "18789"
$env:OPENCLAW_BRIDGE_PORT = "18790"
$env:OPENCLAW_GATEWAY_BIND = "lan"

# Generate random Token
if (-not $env:OPENCLAW_GATEWAY_TOKEN) {
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $env:OPENCLAW_GATEWAY_TOKEN = [BitConverter]::ToString($bytes).Replace("-", "").ToLower()
    $rng.Dispose()
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Image: $env:OPENCLAW_IMAGE" -ForegroundColor White
Write-Host "  Config Dir: $env:OPENCLAW_CONFIG_DIR" -ForegroundColor White
Write-Host "  Workspace Dir: $env:OPENCLAW_WORKSPACE_DIR" -ForegroundColor White
Write-Host "  Gateway Port: $env:OPENCLAW_GATEWAY_PORT" -ForegroundColor White
Write-Host "  Bridge Port: $env:OPENCLAW_BRIDGE_PORT" -ForegroundColor White
Write-Host "  Gateway Token: $env:OPENCLAW_GATEWAY_TOKEN" -ForegroundColor White
Write-Host ""

# Create config directories
if (-not (Test-Path $env:OPENCLAW_CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $env:OPENCLAW_CONFIG_DIR -Force | Out-Null
    Write-Host "Created config directory: $env:OPENCLAW_CONFIG_DIR" -ForegroundColor Green
}

if (-not (Test-Path $env:OPENCLAW_WORKSPACE_DIR)) {
    New-Item -ItemType Directory -Path $env:OPENCLAW_WORKSPACE_DIR -Force | Out-Null
    Write-Host "Created workspace directory: $env:OPENCLAW_WORKSPACE_DIR" -ForegroundColor Green
}

# Check if image exists
$imageExists = docker images -q $env:OPENCLAW_IMAGE 2>$null
if (-not $imageExists) {
    Write-Host "Image $env:OPENCLAW_IMAGE does not exist" -ForegroundColor Red
    Write-Host "Please run build command first: docker build -t openclaw:local -f Dockerfile.cn ." -ForegroundColor Yellow
    exit 1
}

Write-Host "Image exists: $env:OPENCLAW_IMAGE" -ForegroundColor Green

# Start gateway
Write-Host ""
Write-Host "Starting OpenClaw Gateway..." -ForegroundColor Green
docker compose -f docker-compose.cn.yml up -d openclaw-gateway

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "OpenClaw Gateway is running!" -ForegroundColor Green
Write-Host ""
Write-Host "Access Information:" -ForegroundColor Cyan
Write-Host "  Control Panel: http://localhost:$env:OPENCLAW_GATEWAY_PORT" -ForegroundColor White
Write-Host "  Gateway Token: $env:OPENCLAW_GATEWAY_TOKEN" -ForegroundColor White
Write-Host ""
Write-Host "Common Commands:" -ForegroundColor Cyan
Write-Host "  View logs: docker compose -f docker-compose.cn.yml logs -f openclaw-gateway" -ForegroundColor White
Write-Host "  Stop service: docker compose -f docker-compose.cn.yml down" -ForegroundColor White
Write-Host "  Run CLI: docker compose -f docker-compose.cn.yml run --rm openclaw-cli" -ForegroundColor White
Write-Host "  Health check: docker compose -f docker-compose.cn.yml exec openclaw-gateway node dist/index.js health --token `"$env:OPENCLAW_GATEWAY_TOKEN`"" -ForegroundColor White
Write-Host ""

# Save configuration to file
$envContent = @"
OPENCLAW_IMAGE=$env:OPENCLAW_IMAGE
OPENCLAW_CONFIG_DIR=$env:OPENCLAW_CONFIG_DIR
OPENCLAW_WORKSPACE_DIR=$env:OPENCLAW_WORKSPACE_DIR
OPENCLAW_GATEWAY_PORT=$env:OPENCLAW_GATEWAY_PORT
OPENCLAW_BRIDGE_PORT=$env:OPENCLAW_BRIDGE_PORT
OPENCLAW_GATEWAY_BIND=$env:OPENCLAW_GATEWAY_BIND
OPENCLAW_GATEWAY_TOKEN=$env:OPENCLAW_GATEWAY_TOKEN
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "Configuration saved to .env file" -ForegroundColor Green
