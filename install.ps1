# ============================================================
# OpenClaw 汉化发行版 - Windows 一键安装脚本
# 
# 用法:
#   irm https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.ps1 | iex                    # 安装稳定版
#   & ([scriptblock]::Create((irm https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.ps1))) -Nightly  # 安装最新版
# ============================================================

param(
    [switch]$Nightly,
    [string]$ShengsuanyunKey,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# 版本设置
if ($Nightly) {
    $NpmTag = "nightly"
    $VersionName = "最新版 (Nightly)"
} else {
    $NpmTag = "latest"
    $VersionName = "稳定版"
}

# 帮助信息
if ($Help) {
    Write-Host "OpenClaw 汉化版安装脚本" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  irm https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.ps1 | iex                              # 安装稳定版"
    Write-Host "  iex ""& { `$(irm https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.ps1) } -Nightly""          # 安装最新版"
    Write-Host "  .\install.ps1 -ShengsuanyunKey sk-xxx                           # 安装并配置胜算云"
    Write-Host ""
    Write-Host "选项:"
    Write-Host "  -Nightly            安装最新版（每小时自动构建，追踪上游最新代码）"
    Write-Host "  -ShengsuanyunKey    安装后自动配置胜算云 API（跳过交互式初始化）"
    Write-Host "  -Help               显示帮助信息"
    Write-Host ""
    Write-Host "版本说明:"
    Write-Host "  稳定版 (@latest)   手动发布，经过测试，推荐生产使用"
    Write-Host "  最新版 (@nightly)  每小时自动构建，追踪上游，适合测试"
    Write-Host ""
    Write-Host "胜算云快速配置:"
    Write-Host "  获取 API 密钥: https://shengsuanyun.com"
    Write-Host "  新用户福利: 注册送 10 元体验金！"
    exit 0
}


# 检查 Node.js
function Test-NodeVersion {
    try {
        $nodeVersion = node -v 2>$null
        if (-not $nodeVersion) {
            throw "Node.js not found"
        }
        
        $versionNum = $nodeVersion -replace 'v', ''
        $majorVersion = [int]($versionNum.Split('.')[0])
        
        if ($majorVersion -lt 22) {
            Write-Host "❌ Node.js 版本过低: $nodeVersion" -ForegroundColor Red
            Write-Host ""
            Write-Host "OpenClaw 需要 Node.js >= 22.12.0" -ForegroundColor Yellow
            Write-Host "请访问 https://nodejs.org/ 下载最新版本" -ForegroundColor Yellow
            Write-Host ""
            exit 1
        }
        
        Write-Host "✓ Node.js 版本: $nodeVersion" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ 未检测到 Node.js" -ForegroundColor Red
        Write-Host ""
        Write-Host "请先安装 Node.js 22.12.0 或更高版本：" -ForegroundColor Yellow
        Write-Host "  官网: https://nodejs.org/" -ForegroundColor White
        Write-Host ""
        exit 1
    }
}

# 检查 npm
function Test-Npm {
    try {
        $npmVersion = npm -v 2>$null
        Write-Host "✓ npm 版本: v$npmVersion" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ 未检测到 npm" -ForegroundColor Red
        exit 1
    }
}

# 检查环境并准备安装
function Prepare-Installation {
    Write-Host "🔍 环境检查..." -ForegroundColor Blue
    Test-NodeVersion
    Test-Npm

    # 检测是否在本项目源码目录下
    if ((Test-Path ".\cli") -and (Test-Path ".\translations") -and (Test-Path ".\openclaw")) {
        Write-Host "📂 检测到您当前处于 OpenClaw 汉化版源码目录" -ForegroundColor Yellow
        $choice = Read-Host "是否直接对本地 './openclaw' 源码进行汉化？(y/n)"
        if ($choice -eq 'y') {
            Write-Host "🛠️  正在应用本地汉化补丁..." -ForegroundColor Blue
            node cli/index.mjs apply --target=./openclaw
            exit 0
        }
    }

    # 检查原版 OpenClaw 是否已安装
    $installed = npm list -g openclaw 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠ 正在安装原版 OpenClaw..." -ForegroundColor Yellow
        npm install -g openclaw
    }
}

# 安装/运行汉化补丁 (通过 npx)
function Invoke-ChinesePatch {
    Write-Host "📦 正在获取并应用汉化补丁..." -ForegroundColor Blue
    
    # 使用 npx 运行补丁工具
    & npx -y "@qingchencloud/openclaw-zh@$NpmTag" apply
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 汉化失败" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ 汉化成功！" -ForegroundColor Green
}

# 运行安装后自动初始化 (条件性)
function Invoke-SetupIfNeeded {
    $ConfigPath = Join-Path $env:USERPROFILE ".openclaw\openclaw.json"
    
    # CI 环境跳过
    if ($env:CI -eq "true") {
        Write-Host "⚠ 检测到 CI 环境，跳过自动初始化" -ForegroundColor Yellow
        return
    }
    
    # 用户明确跳过
    if ($env:OPENCLAW_SKIP_SETUP -eq "1") {
        Write-Host "⚠ OPENCLAW_SKIP_SETUP=1，跳过自动初始化" -ForegroundColor Yellow
        return
    }
    
    # 如果提供了胜算云 Key，执行胜算云专属非交互式 onboard
    if ($ShengsuanyunKey) {
        Write-Host ""
        Write-Host "🔧 正在配置胜算云..." -ForegroundColor Blue
        Write-Host ""
        
        try {
            & openclaw onboard --non-interactive `
                --auth-choice shengsuanyun-api-key `
                --shengsuanyun-api-key $ShengsuanyunKey `
                --accept-risk 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ 胜算云配置完成！" -ForegroundColor Green
            } else {
                throw "onboard failed"
            }
        } catch {
            # 降级：设置环境变量后重试
            $env:SHENGSUANYUN_API_KEY = $ShengsuanyunKey
            try {
                & openclaw onboard --non-interactive `
                    --auth-choice shengsuanyun-api-key `
                    --accept-risk 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✓ 胜算云配置完成（环境变量模式）！" -ForegroundColor Green
                } else {
                    throw "retry failed"
                }
            } catch {
                Write-Host "⚠ 胜算云自动配置失败，请手动运行:" -ForegroundColor Yellow
                Write-Host "   openclaw onboard"
                Write-Host "   然后在认证选项中选择 '胜算云 API 密钥'"
            }
        }
        return
    }
    
    # 已有配置则跳过
    if (Test-Path $ConfigPath) {
        Write-Host "⚠ 检测到已有配置 ($ConfigPath)，跳过自动初始化" -ForegroundColor Yellow
        return
    }
    
    Write-Host "🔧 自动初始化..." -ForegroundColor Blue
    
    # 尝试运行非交互式 setup
    try {
        $null = openclaw setup --non-interactive 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ 自动初始化完成" -ForegroundColor Green
        } else {
            Write-Host "⚠ 自动初始化跳过（可能需要交互），请手动运行: openclaw onboard" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠ 自动初始化跳过（可能需要交互），请手动运行: openclaw onboard" -ForegroundColor Yellow
    }
}

# 成功信息
function Show-Success {
    Write-Host "✅ OpenClaw 汉化版安装成功！" -ForegroundColor Green
    Write-Host "🚀 快速开始：" -ForegroundColor Cyan
    Write-Host "   openclaw onboard          # 启动初始化向导"
    Write-Host "   openclaw dashboard        # 打开控制面板"
    Write-Host ""
    Write-Host "详细文档: https://openclaw.qt.cool/"
}

# 主流程
function Main {
    Test-Environment
    Invoke-ChinesePatch
    Invoke-SetupIfNeeded
    Show-Success
}

# 执行
Main
