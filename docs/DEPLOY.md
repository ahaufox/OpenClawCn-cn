# 部署指南

<p align="center">
  <a href="../README.md">首页</a> ·
  <a href="USAGE.md">使用指南</a> ·
  <b>部署指南</b> ·
  <a href="DOCKER_GUIDE.md">Docker 部署</a> ·
  <a href="FAQ.md">常见问题</a>
</p>

本文档详细介绍 OpenClaw 汉化版的各类部署方式（非 Docker）。如需使用 Docker 部署，请参考 **[Docker 部署指南](DOCKER_GUIDE.md)**。

---

## 目录

- [前提条件](#prerequisites)
- [快速上手 (npm)](#quickstart)
- [一键安装脚本](#scripts)
- [国内加速安装](#acceleration)
- [手机端部署 (ClawApp)](#mobile)
- [其他安装方式](#other-methods)

---

<a id="prerequisites"></a>
## 前提条件

- **Node.js >= 22**（[下载 Node.js](https://nodejs.org/)）
- 检查版本：`node -v`

---

<a id="quickstart"></a>
## 快速上手 (npm)

这是手动安装的最简单方式：

### 第 1 步：安装
```bash
npm install -g @qingchencloud/openclaw-zh@latest
```

### 第 2 步：初始化（推荐守护进程模式）
```bash
openclaw onboard --install-daemon
```
初始化向导会引导你完成：选择 AI 模型 → 配置 API 密钥 → 设置聊天通道。

### 第 3 步：启动网关
```bash
openclaw gateway
```

### 第 4 步：打开控制台
```bash
openclaw dashboard
```

---

<a id="scripts"></a>
## 一键安装脚本

适用于快速部署环境。

**Linux / macOS：**
```bash
curl -fsSL -o install.sh https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh && bash install.sh
```

**Windows PowerShell：**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.ps1" -OutFile "install.ps1" -Encoding UTF8; powershell -ExecutionPolicy Bypass -File ".\install.ps1"
```

---

<a id="acceleration"></a>
## 国内加速安装

```bash
# 使用 npmmirror 镜像源（国内推荐）
npm install -g @qingchencloud/openclaw-zh@latest --registry=https://registry.npmmirror.com

# 或全局设置镜像源后再安装
npm config set registry https://registry.npmmirror.com
npm install -g @qingchencloud/openclaw-zh@latest
```

---

<a id="mobile"></a>
## 手机端部署 — ClawApp

> **想用手机和 AI 智能体聊天？** [ClawApp](https://github.com/qingchencloud/clawapp) 是 OpenClaw 的移动端 H5 聊天客户端。

OpenClaw Gateway 默认只监听本机（`127.0.0.1:18789`），手机无法直接连接。ClawApp 通过 WebSocket 代理解决了这个问题。

**快速部署**（Docker 一键启动）：

```bash
git clone https://github.com/qingchencloud/clawapp.git
cd clawapp

# 创建 .env，填入你的 Token
echo 'PROXY_TOKEN=设置一个连接密码' > .env
echo 'OPENCLAW_GATEWAY_TOKEN=你的gateway-token' >> .env

docker compose up -d --build
```

手机浏览器打开 `http://你的电脑IP:3210` 即可使用。

---

<a id="other-methods"></a>
## 其他安装方式

### pnpm / yarn 安装
```bash
# pnpm
pnpm add -g @qingchencloud/openclaw-zh@latest

# yarn
yarn global add @qingchencloud/openclaw-zh@latest
```

### Git 克隆加速
```bash
# 方案 1: 使用 GitHub 代理
git clone https://ghproxy.net/https://github.com/1186258278/OpenClawChineseTranslation.git

# 方案 2: 无需 git，直接用 npx 运行
npx @qingchencloud/openclaw-zh@latest
```

---

<p align="right"><a href="#top">回到顶部</a></p>
