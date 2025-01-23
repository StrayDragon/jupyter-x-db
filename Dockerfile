# 构建阶段
FROM python:3.11-slim-bullseye AS builder

# 构建参数
ARG USE_CN_MIRRORS=false
ARG PYTHON_VERSION=3.11
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=notroot
ARG JUPYTER_PORT=8888

# 环境变量
ENV USERNAME=${USERNAME} \
    JUPYTER_PORT=${JUPYTER_PORT} \
    JUPYTER_TOKEN="" \
    JUPYTER_LAB_DIR=/opt/workspace \
    JUPYTER_RUNTIME_DIR=/opt/workspace/.jupyter/runtime \
    JUPYTER_CONFIG_DIR=/opt/workspace/.jupyter/config \
    JUPYTER_DATA_DIR=/opt/workspace/.jupyter/data

# 配置中国镜像源（如果需要）
COPY config/mirrors/cn/debian_bullseye_config /tmp/sources.list
COPY config/mirrors/cn/pypi_config /tmp/pip.conf
RUN if [ "$USE_CN_MIRRORS" = "true" ]; then \
        cp /tmp/sources.list /etc/apt/sources.list && \
        mkdir -p /etc/pip && \
        cp /tmp/pip.conf /etc/pip/pip.conf; \
    fi

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python开发依赖
    python3-dev \
    # 数据库依赖
    default-libmysqlclient-dev \
    # 编译工具
    build-essential \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建非root用户和必要目录
RUN groupadd -g ${GROUP_ID} ${USERNAME} \
    && useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME} \
    && install -d -m 755 -o ${USERNAME} -g ${USERNAME} \
        ${JUPYTER_LAB_DIR} \
        ${JUPYTER_RUNTIME_DIR} \
        ${JUPYTER_CONFIG_DIR} \
        ${JUPYTER_DATA_DIR} \
        /home/${USERNAME}/.local

# 切换到非root用户
USER ${USERNAME}

# 安装Python依赖
RUN pip install --user --no-cache-dir \
    jupyterlab \
    jupysql \
    ipywidgets \
    pandas \
    polars \
    pyarrow \
    numpy \
    matplotlib \
    mysqlclient \
    psycopg2-binary

# 运行阶段
FROM python:3.11-slim-bullseye

# 复制构建阶段的用户和目录设置
ARG USERNAME
ARG USER_ID
ARG GROUP_ID
ENV USERNAME=${USERNAME} \
    JUPYTER_PORT=${JUPYTER_PORT} \
    JUPYTER_TOKEN="" \
    JUPYTER_LAB_DIR=/opt/workspace \
    JUPYTER_RUNTIME_DIR=/opt/workspace/.jupyter/runtime \
    JUPYTER_CONFIG_DIR=/opt/workspace/.jupyter/config \
    JUPYTER_DATA_DIR=/opt/workspace/.jupyter/data \
    PATH="/home/${USERNAME}/.local/bin:$PATH"

# 创建用户和组
RUN groupadd -g ${GROUP_ID} ${USERNAME} \
    && useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME} \
    && install -d -m 755 -o ${USERNAME} -g ${USERNAME} \
        ${JUPYTER_LAB_DIR} \
        ${JUPYTER_RUNTIME_DIR} \
        ${JUPYTER_CONFIG_DIR} \
        ${JUPYTER_DATA_DIR} \
        /home/${USERNAME}/.local

# 复制构建阶段的Python包
COPY --from=builder --chown=${USERNAME}:${USERNAME} /home/${USERNAME}/.local /home/${USERNAME}/.local

# 切换到工作目录
WORKDIR ${JUPYTER_LAB_DIR}

# 切换到非root用户
USER ${USERNAME}

# 暴露端口
EXPOSE ${JUPYTER_PORT}

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${JUPYTER_PORT}/api || exit 1

# 启动Jupyter
CMD ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=${JUPYTER_PORT} --no-browser --NotebookApp.token=${JUPYTER_TOKEN:-$(openssl rand -hex 24)} --notebook-dir=${JUPYTER_LAB_DIR}"]

# 添加元数据
LABEL maintainer="L8ng <straydragonl@foxmail.com>" \
      version="1.0" \
      description="Out of box Jupyter(Lab) with DB Kernel JupySQL" \
      python.version="${PYTHON_VERSION}"
