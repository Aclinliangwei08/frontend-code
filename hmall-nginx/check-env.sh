#!/bin/bash

# Mac环境检查脚本 - 检查nginx和依赖环境

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Hmall 前端环境检查 (Mac版)${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 检查操作系统
echo -e "${YELLOW}[1] 检查操作系统${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✓ 操作系统: macOS $(sw_vers -productVersion)${NC}"
else
    echo -e "${RED}✗ 非macOS系统，此脚本专为macOS设计${NC}"
fi
echo ""

# 检查Homebrew
echo -e "${YELLOW}[2] 检查包管理器${NC}"
if command -v brew &> /dev/null; then
    echo -e "${GREEN}✓ Homebrew已安装: $(brew --version | head -1)${NC}"
else
    echo -e "${RED}✗ Homebrew未安装${NC}"
    echo -e "   安装命令: ${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
fi
echo ""

# 检查Nginx
echo -e "${YELLOW}[3] 检查Nginx${NC}"
if command -v nginx &> /dev/null; then
    nginx_version=$(nginx -v 2>&1)
    echo -e "${GREEN}✓ Nginx已安装: $nginx_version${NC}"
    
    # 检查nginx配置
    nginx_config=$(nginx -t 2>&1)
    if echo "$nginx_config" | grep -q "syntax is ok"; then
        echo -e "${GREEN}✓ Nginx默认配置语法正确${NC}"
    else
        echo -e "${YELLOW}⚠ Nginx默认配置可能有问题${NC}"
    fi
else
    echo -e "${RED}✗ Nginx未安装${NC}"
    echo -e "   安装命令: ${YELLOW}brew install nginx${NC}"
fi
echo ""

# 检查端口占用
echo -e "${YELLOW}[4] 检查端口占用情况${NC}"
ports=(80 8080 18080 18081 18082)
for port in "${ports[@]}"; do
    if lsof -i :$port &> /dev/null; then
        process=$(lsof -i :$port | tail -1 | awk '{print $1" (PID:"$2")"}')
        echo -e "${YELLOW}⚠ 端口 $port 被占用: $process${NC}"
    else
        echo -e "${GREEN}✓ 端口 $port 可用${NC}"
    fi
done
echo ""

# 检查项目文件结构
echo -e "${YELLOW}[5] 检查项目文件结构${NC}"
project_files=(
    "conf/nginx.conf"
    "html/hmall-portal/index.html"
    "html/hmall-admin/users.html"
    "html/hm-refresh-admin/index.html"
)

for file in "${project_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file 存在${NC}"
    else
        echo -e "${RED}✗ $file 不存在${NC}"
    fi
done
echo ""

# 检查日志目录
echo -e "${YELLOW}[6] 检查日志目录${NC}"
if [ -d "logs" ]; then
    echo -e "${GREEN}✓ logs目录存在${NC}"
    echo -e "   权限: $(ls -ld logs | awk '{print $1}')"
else
    echo -e "${YELLOW}⚠ logs目录不存在，将创建${NC}"
    mkdir -p logs
    echo -e "${GREEN}✓ logs目录已创建${NC}"
fi
echo ""

# 检查临时目录
echo -e "${YELLOW}[7] 检查临时目录${NC}"
temp_dirs=("temp/client_body_temp" "temp/proxy_temp" "temp/fastcgi_temp" "temp/scgi_temp" "temp/uwsgi_temp")
for dir in "${temp_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ $dir 存在${NC}"
    else
        echo -e "${YELLOW}⚠ $dir 不存在，将创建${NC}"
        mkdir -p "$dir"
        echo -e "${GREEN}✓ $dir 已创建${NC}"
    fi
done
echo ""

# 检查nginx配置文件
echo -e "${YELLOW}[8] 检查项目nginx配置${NC}"
if [ -f "conf/nginx.conf" ]; then
    # 测试配置语法
    config_test=$(nginx -t -c "$(pwd)/conf/nginx.conf" -p "$(pwd)/" 2>&1)
    if echo "$config_test" | grep -q "syntax is ok"; then
        echo -e "${GREEN}✓ 项目nginx配置语法正确${NC}"
    else
        echo -e "${RED}✗ 项目nginx配置语法错误${NC}"
        echo "$config_test"
    fi
else
    echo -e "${RED}✗ nginx配置文件不存在${NC}"
fi
echo ""

# 网络连通性检查
echo -e "${YELLOW}[9] 检查网络连通性${NC}"
# 检查本地回环
if ping -c 1 127.0.0.1 &> /dev/null; then
    echo -e "${GREEN}✓ 本地回环网络正常${NC}"
else
    echo -e "${RED}✗ 本地回环网络异常${NC}"
fi

# 检查localhost解析
if ping -c 1 localhost &> /dev/null; then
    echo -e "${GREEN}✓ localhost解析正常${NC}"
else
    echo -e "${RED}✗ localhost解析异常${NC}"
fi
echo ""

# 系统资源检查
echo -e "${YELLOW}[10] 系统资源检查${NC}"
# CPU核心数
cpu_cores=$(sysctl -n hw.ncpu)
echo -e "${GREEN}✓ CPU核心数: $cpu_cores${NC}"

# 内存信息
memory_gb=$(echo "scale=1; $(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)
echo -e "${GREEN}✓ 系统内存: ${memory_gb}GB${NC}"

# 磁盘空间
disk_space=$(df -h . | tail -1 | awk '{print "使用:"$3" 可用:"$4" 使用率:"$5}')
echo -e "${GREEN}✓ 磁盘空间: $disk_space${NC}"
echo ""

# 总结
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}          检查完成${NC}"
echo -e "${BLUE}================================${NC}"

# 统计检查结果
errors=$(grep -o "✗" <<< "$(cat /tmp/check_output 2>/dev/null)" | wc -l)
warnings=$(grep -o "⚠" <<< "$(cat /tmp/check_output 2>/dev/null)" | wc -l)

if command -v nginx &> /dev/null && [ -f "conf/nginx.conf" ]; then
    echo -e "${GREEN}🎉 环境检查基本通过，可以尝试启动服务${NC}"
    echo -e "   运行命令: ${YELLOW}./start.sh start${NC}"
else
    echo -e "${RED}❌ 环境检查发现问题，请先解决以下问题：${NC}"
    if ! command -v nginx &> /dev/null; then
        echo -e "   1. 安装nginx: ${YELLOW}brew install nginx${NC}"
    fi
    if [ ! -f "conf/nginx.conf" ]; then
        echo -e "   2. 确保nginx配置文件存在"
    fi
fi

echo ""
echo -e "${BLUE}如需帮助，请查看README-mac.md文档${NC}"