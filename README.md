# Docker Jupyter JupySQL

一个开箱即用的 JupyterLab Docker 镜像，集成了 JupySQL 内核，让您可以在 Jupyter Notebook 中直接运行 SQL 查询。

## 特性

- 🚀 开箱即用的 JupyterLab 环境
- 🔍 内置 JupySQL 支持，直接在 Notebook 中查询数据库
- 🛡️ 安全的非 root 用户运行
- 🔄 支持多种数据库（MySQL, PostgreSQL 等）
- 🇨🇳 中国镜像源支持(可配置)
- 📊 预装数据分析常用库（pandas, numpy, matplotlib 等）

## 快速开始

1. 克隆仓库：
```bash
git clone https://github.com/straydragon/docker-jupyter-jupysql.git
cd docker-jupyter-jupysql
```

2. 构建并运行（基础版）：
```bash
docker build -t jupyter-sql .
docker run -p 8888:8888 -v $(pwd)/notebooks:/opt/workspace/notebooks jupyter-sql
```

访问 http://localhost:8888 即可使用（Token 会在控制台输出）

## 配置选项

### 构建参数

- `USE_CN_MIRRORS`: 是否使用中国镜像源（默认：false）
- `PYTHON_VERSION`: Python 版本（默认：3.11）
- `USER_ID`: 用户 ID（默认：1000）
- `GROUP_ID`: 用户组 ID（默认：1000）
- `JUPYTER_PORT`: JupyterLab 端口（默认：8888）

示例：
```bash
docker build -t jupyter-sql \
  --build-arg USE_CN_MIRRORS=true \
  --build-arg PYTHON_VERSION=3.11 .
```

### 环境变量

- `JUPYTER_TOKEN`: 访问令牌（默认：随机生成）
- `JUPYTER_LAB_DIR`: 工作目录（默认：/opt/workspace）

## 与数据库集成

### 基础示例（MySQL）

```yaml
services:
  jupyterlab:
    build: .
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/opt/workspace/notebooks
    environment:
      - MYSQL_HOST=mysql
      - MYSQL_PORT=3306

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=mydb
```

### 在 Notebook 中使用

```python
%load_ext sql
%sql mysql://user:password@mysql:3306/mydb

%%sql
SELECT * FROM mytable LIMIT 5;
```

## 常见问题

### Q: 如何修改 JupyterLab 访问密码？
A: 设置环境变量 `JUPYTER_TOKEN` 即可：
```bash
docker run -p 8888:8888 -e JUPYTER_TOKEN=mypassword jupyter-sql
```

### Q: 如何使用中国镜像源？
A: 构建时添加参数：
```bash
docker build -t jupyter-sql --build-arg USE_CN_MIRRORS=true .
```

### Q: 如何持久化 Jupyter 配置？
A: 挂载配置目录：
```bash
docker run -p 8888:8888 \
  -v $(pwd)/config/jupyter:/opt/workspace/.jupyter \
  jupyter-sql
```

## 相关链接

- [JupySQL 文档](https://jupysql.ploomber.io/en/latest/quick-start.html)
- [JupyterLab 文档](https://jupyterlab.readthedocs.io/)
- [Docker 文档](https://docs.docker.com/)
