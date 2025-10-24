#!/bin/bash

# 停止nginx服务的独立脚本

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}正在停止Hmall Nginx服务...${NC}"

# 查找nginx进程
nginx_pids=$(pgrep -f nginx)

if [ -z "$nginx_pids" ]; then
    echo -e "${YELLOW}⚠ 没有找到运行中的nginx进程${NC}"
else
    echo "找到nginx进程: $nginx_pids"
    
    # 优雅停止nginx
    echo "尝试优雅停止..."
    pkill -TERM nginx
    
    # 等待2秒
    sleep 2
    
    # 检查是否还有进程
    if pgrep -f nginx > /dev/null; then
        echo -e "${YELLOW}强制终止剩余进程...${NC}"
        pkill -9 -f nginx
        sleep 1
    fi
    
    # 最终确认
    if pgrep -f nginx > /dev/null; then
        echo -e "${RED}✗ 部分nginx进程可能仍在运行${NC}"
        echo "剩余进程："
        ps aux | grep nginx | grep -v grep
    else
        echo -e "${GREEN}✓ 所有nginx进程已停止${NC}"
    fi
fi

# 清理可能的临时文件
if [ -f "logs/nginx.pid" ]; then
    rm -f "logs/nginx.pid"
    echo -e "${GREEN}✓ 清理PID文件${NC}"
fi

echo -e "${GREEN}✓ 停止完成${NC}"