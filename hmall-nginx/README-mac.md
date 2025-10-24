# Hmall 前端项目 - Mac 版部署指南

## 项目概述

这是一个基于 Nginx 的前端项目，包含三个独立的 Web 应用：

- **门户网站** (hmall-portal) - 端口 18080
- **管理后台** (hmall-admin) - 端口 18081
- **刷新管理** (hm-refresh-admin) - 端口 18082

所有应用都通过 `/api` 路径代理到后端服务 `http://localhost:8080`

## 系统要求

- **操作系统**: macOS 10.14+
- **依赖软件**: Nginx 1.15+
- **包管理器**: Homebrew (推荐)
- **后端服务**: 运行在 localhost:8080

## 快速开始

### 1. 环境检查

首先运行环境检查脚本：

```bash
./check-env.sh
```

该脚本会检查：

- 操作系统兼容性
- Homebrew 安装状态
- Nginx 安装和配置
- 端口占用情况
- 项目文件完整性
- 系统资源状况

### 2. 安装依赖

如果环境检查发现缺少依赖，请按以下步骤安装：

#### 安装 Homebrew (如未安装)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 安装 Nginx

```bash
brew install nginx
```

### 3. 启动服务

#### 交互式启动 (推荐)

```bash
./start.sh
```

然后选择相应的操作：

- `1` - 检查环境
- `2` - 启动服务
- `3` - 停止服务
- `4` - 重启服务
- `5` - 查看状态

#### 命令行启动

```bash
# 启动服务
./start.sh start

# 停止服务
./start.sh stop

# 重启服务
./start.sh restart

# 查看状态
./start.sh status
```

### 4. 访问应用

启动成功后，可以通过以下地址访问：

- **门户网站**: http://localhost:18080
- **管理后台**: http://localhost:18081
- **刷新管理**: http://localhost:18082
- **默认重定向**: http://localhost (重定向到门户网站)

## 配置说明

### Nginx 优化配置

项目针对 Mac 系统进行了以下优化：

- **事件模型**: 使用 `kqueue` (Mac 原生高效事件机制)
- **进程数**: 自动检测 CPU 核心数
- **Gzip 压缩**: 启用静态文件压缩
- **缓存策略**: 静态资源 1 年缓存
- **跨域支持**: 完整的 CORS 配置

### API 代理配置

所有 `/api` 请求会被代理到 `http://localhost:8080`，包含：

- 请求头转发 (Host, X-Real-IP, X-Forwarded-For 等)
- 超时设置 (连接/发送/读取均 30 秒)
- 跨域处理 (支持 OPTIONS 预检)
- URL 重写 (去除 `/api` 前缀)

### 目录结构

```
hmall-nginx/
├── conf/
│   └── nginx.conf          # Nginx配置文件
├── html/                   # 静态文件目录
│   ├── hmall-portal/       # 门户网站
│   ├── hmall-admin/        # 管理后台
│   └── hm-refresh-admin/   # 刷新管理
├── logs/                   # 日志目录
├── temp/                   # 临时文件目录
├── start.sh               # 启动脚本
├── check-env.sh           # 环境检查脚本
└── README-mac.md          # 本文档
```

## 故障排除

### 常见问题

#### 1. 端口被占用

```bash
# 查看端口占用
lsof -i :18080

# 终止占用进程
kill -9 <PID>
```

#### 2. Nginx 启动失败

```bash
# 检查配置文件语法
nginx -t -c $(pwd)/conf/nginx.conf -p $(pwd)/

# 查看错误日志
tail -f logs/error.log
```

#### 3. 权限问题

```bash
# 确保脚本有执行权限
chmod +x start.sh check-env.sh

# 确保日志目录可写
chmod 755 logs/
```

#### 4. 后端连接失败

确保后端服务正在运行：

```bash
# 检查后端服务状态
curl -I http://localhost:8080/health

# 或者检查端口监听
lsof -i :8080
```

### 日志调试

#### 访问日志

```bash
tail -f logs/access.log
```

#### 错误日志

```bash
tail -f logs/error.log
```

#### 实时监控

```bash
# 监控所有日志
tail -f logs/*.log
```

## 开发模式

### 文件监控

如需自动重载配置，可以使用 `fswatch`:

```bash
# 安装fswatch
brew install fswatch

# 监控配置文件变化并自动重启
fswatch -o conf/nginx.conf | xargs -n1 -I{} ./start.sh restart
```

### 本地开发

1. 确保后端服务运行在 `localhost:8080`
2. 修改前端文件后无需重启 Nginx (静态文件)
3. 修改 Nginx 配置后需要重启服务

## 性能优化

### 系统级优化

```bash
# 增加文件描述符限制
ulimit -n 65536

# 查看当前限制
ulimit -a
```

### Nginx 调优

根据 Mac 系统特点，已进行以下调优：

- 使用 `sendfile` 和 `tcp_nopush` 提高文件传输效率
- 启用 `gzip` 压缩减少传输大小
- 设置合适的 `worker_connections`
- 配置静态文件缓存策略

## 安全建议

1. **生产环境部署**：

   - 修改默认端口
   - 启用 HTTPS
   - 配置防火墙规则

2. **访问控制**：

   - 限制管理后台访问 IP
   - 设置访问频率限制
   - 启用访问日志监控

3. **文件权限**：
   ```bash
   # 设置合适的文件权限
   chmod 644 conf/nginx.conf
   chmod 755 html/
   chmod 755 logs/
   ```

## 更新日志

- **v1.0** - 初始 Mac 版本适配
  - 创建 Mac 启动脚本
  - 优化 Nginx 配置
  - 添加环境检查
  - 完善跨域支持

## 技术支持

如遇到问题，请按以下顺序排查：

1. 运行 `./check-env.sh` 检查环境
2. 查看 `logs/error.log` 错误日志
3. 确认后端服务运行状态
4. 检查防火墙和网络配置

---

**注意**: 这是专为 Mac 系统优化的版本。Windows 用户请使用原版的 `nginx.exe` 和相关脚本。
