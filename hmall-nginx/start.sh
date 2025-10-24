#!/bin/bash

# Mac版nginx启动脚本
# 适配hmall前端项目

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查nginx是否已安装
check_nginx() {
    if command -v nginx &> /dev/null; then
        echo -e "${GREEN}✓ Nginx已安装${NC}"
        nginx -v
        return 0
    else
        echo -e "${RED}✗ Nginx未安装${NC}"
        echo -e "${YELLOW}请先安装nginx: brew install nginx${NC}"
        return 1
    fi
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -i :$port &> /dev/null; then
        echo -e "${YELLOW}⚠ 端口 $port 已被占用${NC}"
        echo "占用进程："
        lsof -i :$port
        return 1
    else
        echo -e "${GREEN}✓ 端口 $port 可用${NC}"
        return 0
    fi
}

# 停止nginx进程
stop_nginx() {
    echo "正在停止nginx进程..."
    
    # 查找并终止nginx进程
    pkill -f nginx
    
    # 确认进程已停止
    sleep 2
    if pgrep -f nginx > /dev/null; then
        echo -e "${YELLOW}强制终止剩余nginx进程${NC}"
        pkill -9 -f nginx
    fi
    
    echo -e "${GREEN}✓ Nginx进程已停止${NC}"
}

# 启动nginx
start_nginx() {
    local config_path="$(pwd)/conf/nginx.conf"
    
    if [ ! -f "$config_path" ]; then
        echo -e "${RED}✗ 配置文件不存在: $config_path${NC}"
        return 1
    fi
    
    echo "使用配置文件: $config_path"
    echo "启动nginx..."
    
    # 使用绝对路径启动nginx
    nginx -c "$config_path" -p "$(pwd)/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Nginx启动成功${NC}"
        echo ""
        echo "服务访问地址："
        echo "  - 门户网站: http://localhost:18080"
        echo "  - 管理后台: http://localhost:18081" 
        echo "  - 刷新管理: http://localhost:18082"
        echo ""
        echo "后端接口代理: http://localhost:8080"
    else
        echo -e "${RED}✗ Nginx启动失败${NC}"
        return 1
    fi
}

# 重启nginx
restart_nginx() {
    echo "重启nginx..."
    stop_nginx
    sleep 1
    start_nginx
}

# 显示状态
show_status() {
    echo "Nginx进程状态："
    if pgrep -f nginx > /dev/null; then
        echo -e "${GREEN}✓ Nginx正在运行${NC}"
        ps aux | grep nginx | grep -v grep
    else
        echo -e "${YELLOW}⚠ Nginx未运行${NC}"
    fi
    
    echo ""
    echo "端口占用情况："
    for port in 80 18080 18081 18082; do
        if lsof -i :$port &> /dev/null; then
            echo -e "${GREEN}端口 $port: 已使用${NC}"
        else
            echo -e "${YELLOW}端口 $port: 空闲${NC}"
        fi
    done
}

# 主菜单
show_menu() {
    echo "================================"
    echo "   Hmall Nginx 管理脚本 (Mac版)"
    echo "================================"
    echo "1) 检查环境"
    echo "2) 启动服务"
    echo "3) 停止服务" 
    echo "4) 重启服务"
    echo "5) 查看状态"
    echo "6) 退出"
    echo "================================"
}

# 主程序
main() {
    # 切换到脚本所在目录
    cd "$(dirname "$0")"
    
    if [ $# -eq 0 ]; then
        # 交互模式
        while true; do
            show_menu
            read -p "请选择操作 [1-6]: " choice
            
            case $choice in
                1)
                    echo "正在检查环境..."
                    check_nginx
                    for port in 80 18080 18081 18082; do
                        check_port $port
                    done
                    ;;
                2)
                    check_nginx && start_nginx
                    ;;
                3)
                    stop_nginx
                    ;;
                4)
                    check_nginx && restart_nginx
                    ;;
                5)
                    show_status
                    ;;
                6)
                    echo "退出"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}无效选择${NC}"
                    ;;
            esac
            
            echo ""
            read -p "按回车键继续..."
            clear
        done
    else
        # 命令行模式
        case $1 in
            start)
                check_nginx && start_nginx
                ;;
            stop)
                stop_nginx
                ;;
            restart)
                check_nginx && restart_nginx
                ;;
            status)
                show_status
                ;;
            check)
                check_nginx
                ;;
            *)
                echo "用法: $0 [start|stop|restart|status|check]"
                echo "或直接运行 $0 进入交互模式"
                exit 1
                ;;
        esac
    fi
}

# 运行主程序
main "$@"