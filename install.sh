#!/bin/bash
# ============================================================
# OpenClaw 汉化发行版 - 一键安装脚本
# 
# 用法:
#   curl -fsSL https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh | bash           # 安装稳定版
#   curl -fsSL https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh | bash -s -- --nightly  # 安装最新版
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认安装稳定版
INSTALL_NIGHTLY=false
NPM_TAG="latest"
VERSION_NAME="稳定版"
SHENGSUANYUN_KEY=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --nightly)
            INSTALL_NIGHTLY=true
            NPM_TAG="nightly"
            VERSION_NAME="最新版 (Nightly)"
            shift
            ;;
        --shengsuanyun-key)
            SHENGSUANYUN_KEY="$2"
            shift 2
            ;;
        --help|-h)
            echo "OpenClaw 汉化版安装脚本"
            echo ""
            echo "用法:"
            echo "  curl -fsSL https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh | bash                   # 安装稳定版"
            echo "  curl -fsSL https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh | bash -s -- --nightly   # 安装最新版"
            echo "  curl -fsSL https://cdn.jsdelivr.net/gh/1186258278/OpenClawChineseTranslation@main/install.sh | bash -s -- --shengsuanyun-key sk-xxx  # 安装并配置胜算云"
            echo ""
            echo "选项:"
            echo "  --nightly              安装最新版（每小时自动构建，追踪上游最新代码）"
            echo "  --shengsuanyun-key KEY 安装后自动配置胜算云 API（跳过交互式初始化）"
            echo "  --help                 显示帮助信息"
            echo ""
            echo "版本说明:"
            echo "  稳定版 (@latest)   手动发布，经过测试，推荐生产使用"
            echo "  最新版 (@nightly)  每小时自动构建，追踪上游，适合测试"
            echo ""
            echo "胜算云快速配置:"
            echo "  获取 API 密钥: https://shengsuanyun.com"
            echo "  新用户福利: 注册送 10 元体验金！"
            exit 0
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            exit 1
            ;;
    esac
done


# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# 检查 Node.js 版本
check_node_version() {
    if ! check_command node; then
        echo -e "${RED}❌ 未检测到 Node.js${NC}"
        echo ""
        echo -e "${YELLOW}请先安装 Node.js 22.12.0 或更高版本：${NC}"
        echo "  官网: https://nodejs.org/"
        echo "  推荐: 使用 nvm 管理 Node.js 版本"
        echo ""
        exit 1
    fi

    NODE_VERSION=$(node -v | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

    if [ "$NODE_MAJOR" -lt 22 ]; then
        echo -e "${RED}❌ Node.js 版本过低: v$NODE_VERSION${NC}"
        echo ""
        echo -e "${YELLOW}OpenClaw 需要 Node.js >= 22.12.0${NC}"
        echo "请升级 Node.js 后重试"
        echo ""
        exit 1
    fi

    echo -e "${GREEN}✓${NC} Node.js 版本: v$NODE_VERSION"
}

# 检查 npm
check_npm() {
    if ! check_command npm; then
        echo -e "${RED}❌ 未检测到 npm${NC}"
        exit 1
    fi
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓${NC} npm 版本: v$NPM_VERSION"
}

# 检查环境并准备安装
prepare_install() {
    echo -e "${BLUE}🔍 环境检查...${NC}"
    check_node_version
    check_npm

    # 检测是否在本项目源码目录下
    if [ -d "./cli" ] && [ -d "./translations" ] && [ -d "./openclaw" ]; then
        echo -e "${YELLOW}📂 检测到您当前处于 OpenClaw 汉化版源码目录${NC}"
        read -p "是否直接对本地 './openclaw' 源码进行汉化？(y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}🛠️  正在应用本地汉化补丁...${NC}"
            node cli/index.mjs apply --target=./openclaw
            exit 0
        fi
    fi

    # 检查原版 OpenClaw 是否已安装
    if ! npm list -g openclaw &> /dev/null; then
        echo -e "${YELLOW}⚠ 正在安装原版 OpenClaw...${NC}"
        npm install -g openclaw
    fi
}

# 安装/运行汉化补丁 (通过 npx)
apply_chinese_patch() {
    echo -e "${BLUE}📦 正在获取并应用汉化补丁...${NC}"
    
    # 使用 npx 运行补丁工具
    if npx -y @qingchencloud/openclaw-zh@${NPM_TAG} apply; then
        echo -e "${GREEN}✓ 汉化成功！${NC}"
    else
        echo -e "${RED}❌ 汉化失败${NC}"
        exit 1
    fi
}

# 运行安装后自动初始化 (条件性)
run_setup_if_needed() {
    local CONFIG_PATH="$HOME/.openclaw/openclaw.json"
    
    # CI 环境跳过
    if [ "$CI" = "true" ]; then
        echo -e "${YELLOW}⚠${NC} 检测到 CI 环境，跳过自动初始化"
        return 0
    fi
    
    # 用户明确跳过
    if [ "$OPENCLAW_SKIP_SETUP" = "1" ]; then
        echo -e "${YELLOW}⚠${NC} OPENCLAW_SKIP_SETUP=1，跳过自动初始化"
        return 0
    fi
    
    # 如果提供了胜算云 Key，执行胜算云专属非交互式 onboard
    if [ -n "$SHENGSUANYUN_KEY" ]; then
        echo ""
        echo -e "${BLUE}🔧 正在配置胜算云...${NC}"
        echo ""
        
        if openclaw onboard --non-interactive \
            --auth-choice shengsuanyun-api-key \
            --shengsuanyun-api-key "$SHENGSUANYUN_KEY" \
            --accept-risk 2>/dev/null; then
            echo -e "${GREEN}✓${NC} 胜算云配置完成！"
        else
            # 降级：设置环境变量后重试
            export SHENGSUANYUN_API_KEY="$SHENGSUANYUN_KEY"
            if openclaw onboard --non-interactive \
                --auth-choice shengsuanyun-api-key \
                --accept-risk 2>/dev/null; then
                echo -e "${GREEN}✓${NC} 胜算云配置完成（环境变量模式）！"
            else
                echo -e "${YELLOW}⚠${NC} 胜算云自动配置失败，请手动运行:"
                echo "   openclaw onboard"
                echo "   然后在认证选项中选择 '胜算云 API 密钥'"
            fi
        fi
        return 0
    fi
    
    # 已有配置则跳过
    if [ -f "$CONFIG_PATH" ]; then
        echo -e "${YELLOW}⚠${NC} 检测到已有配置 ($CONFIG_PATH)，跳过自动初始化"
        return 0
    fi
    
    echo -e "${BLUE}🔧 自动初始化...${NC}"
    
    # 尝试运行非交互式 setup
    if openclaw setup --non-interactive 2>/dev/null; then
        echo -e "${GREEN}✓${NC} 自动初始化完成"
    else
        echo -e "${YELLOW}⚠${NC} 自动初始化跳过（可能需要交互），请手动运行: openclaw onboard"
    fi
}

# 打印成功信息
print_success() {
    echo -e "${GREEN}✅ OpenClaw 汉化版安装成功！${NC}"
    echo -e "${CYAN} 快速开始：${NC}"
    echo "   openclaw onboard          # 启动初始化向导"
    echo "   openclaw dashboard        # 打开控制面板"
    echo ""
    echo "详细文档: https://openclaw.qt.cool/"
}

# 主流程
main() {
    prepare_install
    apply_chinese_patch
    run_setup_if_needed
    print_success
}

# 仅在直接执行时运行 main，被 source 时不执行（用于测试）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
