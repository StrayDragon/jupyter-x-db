FROM python:3.11-slim-bullseye

# 添加元数据
LABEL maintainer="L8ng <straydragonl@foxmail.com>" \
      version="1.0" \
      description="Out of box Jupyter(Lab) with DB Kernel JupySQL"

# 构建参数
ARG USE_CN_MIRRORS=false
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=notroot
ARG ROOT_PASSWORD=isroot

# 环境变量
ENV USER_ID=${USER_ID} \
    GROUP_ID=${GROUP_ID} \
    USERNAME=${USERNAME} \
    ROOT_PASSWORD=${ROOT_PASSWORD} \
    JUPYTER_TOKEN=123456 \
    JUPYTER_BASE_DIR=/opt/workspace \
    PATH="/home/${USERNAME}/.local/bin:$PATH"

# 配置中国镜像源（如果需要）
COPY config/mirrors/cn/debian_bullseye_config /opt/sources.list
COPY config/mirrors/cn/pypi_config /opt/pip.conf
RUN if [ "$USE_CN_MIRRORS" = "true" ]; then \
        cp /opt/sources.list /etc/apt/sources.list && \
        cp /opt/pip.conf /etc/pip.conf; \
    fi

# 安装系统依赖并创建用户
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-dev \
        default-libmysqlclient-dev \
        build-essential \
        pkg-config \
        curl \
    && echo "root:${ROOT_PASSWORD}" | chpasswd \
    && groupadd -g ${GROUP_ID} ${USERNAME} \
    && useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME} \
    && install -d -m 755 -o ${USERNAME} -g ${USERNAME} \
        ${JUPYTER_BASE_DIR} \
        ${JUPYTER_BASE_DIR}/.jupyter/{runtime,config,data} \
        /home/${USERNAME}/.local \
    && su -l ${USERNAME} -c "pip install --user --no-cache-dir \
        jupyterlab \
        jupysql \
        ipywidgets \
        pandas \
        polars \
        pyarrow \
        numpy \
        matplotlib \
        mysqlclient \
        psycopg2-binary" \
    && apt-get purge -y --auto-remove python3-dev build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local

# 切换到非root用户
USER ${USERNAME}


# 设置工作目录和用户
WORKDIR ${JUPYTER_BASE_DIR}

# 暴露端口
EXPOSE 8888

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/api || exit 1

# 启动Jupyter
CMD ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=${JUPYTER_TOKEN} --notebook-dir=${JUPYTER_BASE_DIR}"]
