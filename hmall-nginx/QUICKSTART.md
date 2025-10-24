# 🚀 Mac 快速启动指南

## 一键检查环境

```bash
./check-env.sh
```

## 一键启动服务

```bash
./start.sh start
```

## 访问地址

- 门户网站: http://localhost:18080
- 管理后台: http://localhost:18081
- 刷新管理: http://localhost:18082

## 如果缺少依赖

```bash
# 安装Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装Nginx
brew install nginx
```

## 常用命令

```bash
./start.sh start    # 启动
./start.sh stop     # 停止
./start.sh restart  # 重启
./start.sh status   # 状态
```

详细文档请查看: [README-mac.md](README-mac.md)
