# Jupyter x DB

一个开箱即用的 JupyterLab Docker 镜像，集成了 [JupySQL](https://github.com/ploomber/jupysql) 内核，支持多种数据库源, 并直接在 Jupyter Notebook 中直接运行 SQL 查询。

## 特性

- 🚀 开箱即用的 JupyterLab 环境
- 🔍 内置 JupySQL 支持，直接在 Notebook 中查询数据库
- 🛡️ 安全的非 root 用户运行
- 🔄 内核([jupysql](https://github.com/ploomber/jupysql)) 支持多种数据库, 本镜像默认集成 MySQL, PostgreSQL
- 🇨🇳 中国镜像源支持(可配置)
- 📊 预装数据分析常用库（pandas, numpy, matplotlib 等）

## 快速开始

### 使用 Github Registry (ghcr)

```bash
docker pull ghcr.io/straydragon/jupyter-x-db:latest
cd <a directory which you like>
mkdir -p notebooks
docker run --host -v $(pwd)/notebooks:/opt/workspace/notebooks ghcr.io/straydragon/jupyter-x-db
```
或者复制并参考 [user.docker-compose.yml](./docker-compose.yml) 使用 docker compose 运行


### 本地开发运行

1. 克隆仓库：
```bash
git clone https://github.com/straydragon/docker-jupyter-jupysql.git
cd docker-jupyter-jupysql
```

2. 构建并运行：
```bash
docker build -t jupyter-x-db --build-arg USE_CN_MIRRORS=true  .
mkdir -p notebooks
docker run -p 8888:8888 -v $(pwd)/notebooks:/opt/workspace/notebooks jupyter-x-db
```

访问 http://localhost:8888 即可使用（Token 默认为 123456）

## 配置选项

### 构建参数

- `USE_CN_MIRRORS`: 是否使用中国镜像源（默认：false）
- `USER_ID`: 用户 ID（默认：1000）
- `GROUP_ID`: 用户组 ID（默认：1000）

示例：
```bash
docker build -t jupyter-x-db \
  --build-arg USE_CN_MIRRORS=true \
  .
```

### 环境变量

- `JUPYTER_TOKEN`: 访问令牌（默认：123456）
- `JUPYTER_LAB_DIR`: 工作目录（默认：/opt/workspace）

## 与数据库集成

### 基础示例（MySQL）

参考: [docker-compose.yml](./docker-compose.yml)


### 在 Notebook 中使用

参考: [example.ipynb](./notebooks/example.ipynb)


## 常见问题

### Q: 如何修改 JupyterLab 访问密码？
A: 设置环境变量 `JUPYTER_TOKEN` 即可：
```bash
docker run -p 8888:8888 -e JUPYTER_TOKEN=mypassword jupyter-x-db
```

### Q: 如何使用中国镜像源？
A: 构建时添加参数：
```bash
docker build -t jupyter-x-db --build-arg USE_CN_MIRRORS=true .
```

### Q: 如何持久化 Jupyter 配置？
A: 挂载配置目录：
```bash
docker run -p 8888:8888 \
  -v $(pwd)/config/jupyter:/opt/workspace/.jupyter \
  jupyter-x-db
```

## 相关链接

- [JupySQL 文档](https://jupysql.ploomber.io/en/latest/quick-start.html)