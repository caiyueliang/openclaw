# OpenClaw WSL 设置脚本
# 在 PowerShell 中运行此脚本来设置 WSL 环境

Write-Host "🚀 OpenClaw WSL 设置脚本" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host ""

# 检查 WSL 是否已安装
Write-Host "检查 WSL 状态..." -ForegroundColor Yellow
try {
    $wslCheck = wsl --help 2>&1
    Write-Host "✅ WSL 已安装" -ForegroundColor Green
} catch {
    Write-Host "❌ WSL 未安装，请先安装 WSL" -ForegroundColor Red
    Write-Host "运行: wsl --install" -ForegroundColor Yellow
    exit 1
}

# 检查 Ubuntu 是否已安装
Write-Host ""
Write-Host "检查 Ubuntu 安装状态..." -ForegroundColor Yellow
try {
    $distroCheck = wsl -d Ubuntu -e echo "test" 2>&1
    Write-Host "✅ Ubuntu 已安装" -ForegroundColor Green
} catch {
    Write-Host "❌ Ubuntu 未安装" -ForegroundColor Red
    Write-Host ""
    Write-Host "请从 Microsoft Store 安装 Ubuntu:" -ForegroundColor Yellow
    Write-Host "1. 打开 Microsoft Store" -ForegroundColor Cyan
    Write-Host "2. 搜索 'Ubuntu'" -ForegroundColor Cyan
    Write-Host "3. 点击'获取'按钮安装" -ForegroundColor Cyan
    Write-Host "4. 安装完成后启动 Ubuntu 并设置用户名和密码" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "安装完成后，请重新运行此脚本" -ForegroundColor Yellow
    
    # 打开 Microsoft Store
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4MSV6"
    exit 1
}

Write-Host ""
Write-Host "✅ WSL 和 Ubuntu 已准备就绪!" -ForegroundColor Green
Write-Host ""

# 复制安装脚本到 WSL
$scriptPath = "$PSScriptRoot\install-wsl.sh"
$wslScriptPath = "/tmp/install-wsl.sh"

Write-Host "复制安装脚本到 WSL..." -ForegroundColor Yellow
wsl -d Ubuntu -e mkdir -p /tmp
$wslPath = wsl -d Ubuntu -e wslpath -u "$scriptPath"
wsl -d Ubuntu -e cp "$wslPath" "$wslScriptPath"
wsl -d Ubuntu -e chmod +x "$wslScriptPath"

Write-Host ""
Write-Host "🎉 准备完成!" -ForegroundColor Green
Write-Host ""
Write-Host "接下来请在 Ubuntu 终端中运行:" -ForegroundColor Cyan
Write-Host "  bash /tmp/install-wsl.sh" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "或者手动进入 WSL 并运行:" -ForegroundColor Yellow
Write-Host "  wsl" -ForegroundColor Cyan
Write-Host "  bash /tmp/install-wsl.sh" -ForegroundColor Cyan
Write-Host ""

# 询问是否立即启动 WSL
$startWSL = Read-Host "是否立即启动 WSL? (y/n)"
if ($startWSL -eq 'y' -or $startWSL -eq 'Y') {
    Write-Host ""
    Write-Host "启动 WSL Ubuntu..." -ForegroundColor Green
    Write-Host "请在 Ubuntu 中运行: bash /tmp/install-wsl.sh" -ForegroundColor Yellow
    Write-Host ""
    wsl -d Ubuntu
}
