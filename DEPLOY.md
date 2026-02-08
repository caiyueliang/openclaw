# OpenClaw Docker 部署指南

## 部署状态

✅ **部署成功！** OpenClaw 网关已在本地运行。

## 访问信息

- **控制面板**: http://localhost:18789
- **网关 Token**: `d087beab6ec27dd4851a013dd3bdaa46c199a1abbefcf19b9a8b860ad956b555`
- **网关端口**: 18789
- **网桥端口**: 18790

## 快速开始

### 1. 查看容器状态

```powershell
docker ps
```

### 2. 查看日志

```powershell
docker logs -f openclaw-gateway
```

### 3. 停止服务

```powershell
docker stop openclaw-gateway
docker rm openclaw-gateway
```

### 4. 重新启动

```powershell
docker start openclaw-gateway
```

## 部署步骤（如需重新部署）

### 步骤 1: 构建镜像

由于原镜像 `justlikemaki/openclaw-docker-cn-im:latest` 无法拉取，我们使用项目源码自行构建：

```powershell
# 使用国内镜像源加速
docker pull m.daocloud.io/docker.io/library/node:22-bookworm

# 构建 OpenClaw 镜像
docker build -t openclaw:local -f Dockerfile.cn .
```

### 步骤 2: 启动容器

```powershell
docker run -d `
  --name openclaw-gateway `
  -p 18789:18789 `
  -p 18790:18790 `
  -e HOME=/home/node `
  -e OPENCLAW_GATEWAY_TOKEN=<your-token> `
  openclaw:local `
  node dist/index.js gateway --bind lan --port 18789 --allow-unconfigured
```

### 步骤 3: 验证部署

```powershell
# 查看容器状态
docker ps

# 查看日志
docker logs openclaw-gateway

# 健康检查
docker exec openclaw-gateway node dist/index.js health --token <your-token>
```

## 文件说明

- `Dockerfile.cn` - 使用国内镜像源的 Dockerfile
- `docker-compose.cn.yml` - Docker Compose 配置（国内源）
- `start-openclaw.ps1` - Windows PowerShell 启动脚本
- `.env` - 环境变量配置文件

## 常见问题

### 1. 原镜像无法拉取

原镜像 `justlikemaki/openclaw-docker-cn-im:latest` 不存在或无法访问。

**解决方案**: 使用本项目源码自行构建镜像。

### 2. Docker Hub 连接超时

**解决方案**: 使用国内镜像源 `m.daocloud.io`

### 3. 构建时 PowerShell 错误

Linux 容器中没有 PowerShell。

**解决方案**: 修改 Dockerfile 跳过需要 PowerShell 的步骤，创建空的 A2UI bundle 文件。

### 4. A2UI bundle 缺失

**解决方案**: 在 Dockerfile 中创建占位文件：

```dockerfile
RUN mkdir -p src/canvas-host/a2ui && \
    echo "// A2UI bundle placeholder" > src/canvas-host/a2ui/a2ui.bundle.js
```

## 高级配置

### 使用 Docker Compose

```powershell
# 启动服务
docker compose -f docker-compose.cn.yml up -d openclaw-gateway

# 停止服务
docker compose -f docker-compose.cn.yml down
```

### 运行 CLI 命令

```powershell
docker run --rm -it openclaw:local node dist/index.js --help
```

### 配置持久化

添加卷映射以持久化配置：

```powershell
docker run -d `
  --name openclaw-gateway `
  -p 18789:18789 `
  -v "$env:USERPROFILE\.openclaw:/home/node/.openclaw" `
  -e HOME=/home/node `
  -e OPENCLAW_GATEWAY_TOKEN=<your-token> `
  openclaw:local `
  node dist/index.js gateway --bind lan --port 18789 --allow-unconfigured
```

## 参考链接

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Docker 官方文档](https://docs.docker.com)
