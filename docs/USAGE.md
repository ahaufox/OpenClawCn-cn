# 使用指南

<p align="center">
  <a href="../README.md">首页</a> ·
  <b>使用指南</b> ·
  <a href="DEPLOY.md">部署指南</a> ·
  <a href="DOCKER_GUIDE.md">Docker 部署</a> ·
  <a href="FAQ.md">常见问题</a>
</p>

本文档介绍 OpenClaw 汉化版安装后的日常使用、命令操作、卸载及常见问题快速查阅。

---

## 目录

- [常用命令](#commands)
- [网关重启](#gateway-restart)
- [更新升级](#upgrade)
- [卸载教程](#uninstall)
- [插件扩展](#plugins)
- [常见问题快速排查](#faq-summary)

---


<a id="commands"></a>
## 常用命令

```bash
openclaw                    # 启动 OpenClaw
openclaw onboard            # 初始化向导
openclaw dashboard          # 打开网页控制台
openclaw config             # 查看/修改配置
openclaw skills             # 管理技能
openclaw --help             # 查看帮助

# 网关管理
openclaw gateway run        # 前台运行（挂终端，用于调试）
openclaw gateway start      # 后台守护进程（不挂终端，推荐！）
openclaw gateway stop       # 停止网关
openclaw gateway restart    # 重启网关
openclaw gateway status     # 查看网关状态
openclaw gateway install    # 安装为系统服务（开机自启）

# 常用操作
openclaw update             # 检查并更新 CLI
openclaw doctor             # 诊断问题（自动修复）
```

> **Dashboard 语言设置**：首次打开网页控制台后，前往 **Overview** 页面底部，将 **Language** 切换为 **简体中文 (Simplified Chinese)**，即可显示中文界面。设置后刷新页面生效。

---

<a id="gateway-restart"></a>
## 网关重启

```bash
# 方式 1：使用 gateway 子命令（推荐）
openclaw gateway restart

# 方式 2：先停止再启动
openclaw gateway stop
openclaw gateway start

# 方式 3：守护进程模式（后台运行，不挂终端）
openclaw daemon start       # 启动后台守护
openclaw daemon stop        # 停止守护
openclaw daemon restart    # 重启守护
openclaw daemon status     # 查看状态

# Docker 容器重启
docker restart openclaw
```

---

<a id="upgrade"></a>
## 更新升级

```bash
npm update -g @qingchencloud/openclaw-zh
```

> 查看当前版本：`openclaw --version`

| 版本       | 安装命令                                            | 说明                       |
| ---------- | --------------------------------------------------- | -------------------------- |
| **稳定版** | `npm install -g @qingchencloud/openclaw-zh@latest`  | 经过测试，推荐使用         |
| **最新版** | `npm install -g @qingchencloud/openclaw-zh@nightly` | 每小时同步上游，体验新功能 |

---

<a id="uninstall"></a>
## 卸载教程

### CLI 卸载

```bash
# 卸载汉化版
npm uninstall -g @qingchencloud/openclaw-zh

# 如果之前安装过原版，也一并卸载
npm uninstall -g openclaw
```

### 数据清理（可选）

```bash
# 删除配置和缓存（不可恢复！）
rm -rf ~/.openclaw

# Docker 清理
docker rm -f openclaw                # 删除容器
docker volume rm openclaw-data       # 删除数据卷
```

### 守护进程卸载

```bash
# macOS
launchctl unload ~/Library/LaunchAgents/com.openclaw.plist
rm ~/Library/LaunchAgents/com.openclaw.plist

# Linux (systemd)
sudo systemctl stop openclaw
sudo systemctl disable openclaw
sudo rm /etc/systemd/system/openclaw.service
sudo systemctl daemon-reload
```

---

<a id="plugins"></a>
## 插件扩展

```bash
# 安装更新检测插件
npm install -g @qingchencloud/openclaw-updater
```

访问 [插件市场](https://openclaw.qt.cool/) 获取更多插件。

---

<a id="faq-summary"></a>
## 常见问题快速排查

| 问题                           | 快速解决                                                                        | 详情                                |
| ------------------------------ | ------------------------------------------------------------------------------- | ----------------------------------- |
| **安装报 `Permission denied`** | `git config --global url."https://github.com/".insteadOf ssh://git@github.com/` | [查看 →](FAQ.md#permission-denied)  |
| **远程 / 内网访问不了**        | `openclaw config set gateway.bind lan` 然后重启                                 | [查看 →](FAQ.md#lan-access)         |
| **`Missing config`**           | 运行 `openclaw onboard` 初始化配置                                              | [查看 →](FAQ.md#missing-config)     |
| **Ollama 无响应**              | 检查 baseURL 是否为 `http://localhost:11434/v1`                                 | [查看 →](FAQ.md#ollama-no-response) |

> **[完整排查手册 (25+ 个问题)](FAQ.md)**

---

<p align="right"><a href="#top">回到顶部</a></p>
