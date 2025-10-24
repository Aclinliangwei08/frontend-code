#!/bin/bash

# 配置文件备份和恢复工具

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_DIR="backup"
CONFIG_FILE="conf/nginx.conf"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 创建备份目录
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${GREEN}✓ 创建备份目录: $BACKUP_DIR${NC}"
    fi
}

# 备份配置
backup_config() {
    create_backup_dir
    
    if [ -f "$CONFIG_FILE" ]; then
        backup_file="$BACKUP_DIR/nginx_${TIMESTAMP}.conf"
        cp "$CONFIG_FILE" "$backup_file"
        echo -e "${GREEN}✓ 配置已备份到: $backup_file${NC}"
        
        # 创建符号链接到最新备份
        ln -sf "nginx_${TIMESTAMP}.conf" "$BACKUP_DIR/nginx_latest.conf"
        echo -e "${GREEN}✓ 最新备份链接已更新${NC}"
    else
        echo -e "${RED}✗ 配置文件不存在: $CONFIG_FILE${NC}"
        return 1
    fi
}

# 列出备份
list_backups() {
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${BLUE}可用的备份文件:${NC}"
        ls -la "$BACKUP_DIR"/*.conf 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}⚠ 备份目录不存在${NC}"
    fi
}

# 恢复配置
restore_config() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        # 显示可用备份
        list_backups
        echo ""
        read -p "请输入要恢复的备份文件名 (或按回车使用最新备份): " backup_file
        
        if [ -z "$backup_file" ]; then
            backup_file="$BACKUP_DIR/nginx_latest.conf"
        else
            backup_file="$BACKUP_DIR/$backup_file"
        fi
    fi
    
    if [ -f "$backup_file" ]; then
        # 先备份当前配置
        if [ -f "$CONFIG_FILE" ]; then
            current_backup="$BACKUP_DIR/nginx_before_restore_${TIMESTAMP}.conf"
            cp "$CONFIG_FILE" "$current_backup"
            echo -e "${YELLOW}⚠ 当前配置已备份到: $current_backup${NC}"
        fi
        
        # 恢复配置
        cp "$backup_file" "$CONFIG_FILE"
        echo -e "${GREEN}✓ 配置已从 $backup_file 恢复${NC}"
        
        # 测试配置
        if nginx -t -c "$(pwd)/$CONFIG_FILE" -p "$(pwd)/" &>/dev/null; then
            echo -e "${GREEN}✓ 恢复的配置语法正确${NC}"
        else
            echo -e "${RED}✗ 恢复的配置语法有误${NC}"
            echo "请检查配置文件"
        fi
    else
        echo -e "${RED}✗ 备份文件不存在: $backup_file${NC}"
        return 1
    fi
}

# 显示帮助
show_help() {
    echo "配置文件备份和恢复工具"
    echo ""
    echo "用法:"
    echo "  $0 backup                    # 备份当前配置"
    echo "  $0 restore [备份文件名]      # 恢复配置"
    echo "  $0 list                      # 列出所有备份"
    echo "  $0 help                      # 显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 backup"
    echo "  $0 restore nginx_20231022_143022.conf"
    echo "  $0 restore                   # 恢复最新备份"
}

# 主程序
case "${1:-help}" in
    backup)
        backup_config
        ;;
    restore)
        restore_config "$2"
        ;;
    list)
        list_backups
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}未知操作: $1${NC}"
        show_help
        exit 1
        ;;
esac