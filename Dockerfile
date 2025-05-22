#######################################################################
# 1️⃣ builder —— 自动下载并编译原版 QDP++ / Chroma
#######################################################################
FROM debian:12-slim AS builder

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential cmake git ninja-build \
    libopenmpi-dev openmpi-bin \
    libhdf5-dev libpng-dev zlib1g-dev libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置构建目录
WORKDIR /src

# 自动克隆源码
RUN git clone --recursive https://github.com/usqcd-software/qmp.git && \
    git clone --recursive https://github.com/usqcd-software/qdpxx.git && git checkout devel && \
    git clone --recursive https://github.com/JeffersonLab/chroma.git && git checkout devel

# 编译脚本
COPY build.sh /src
RUN chmod +x ./build.sh && \
    sed -i 's|^ROOT=.*|ROOT=/src|' build.sh && \
    sed -i 's|DST=.*|DST=/opt/chroma|' build.sh && \
    ./build.sh

#######################################################################
# 2️⃣ runtime —— 仅保留运行必需文件
#######################################################################
FROM debian:12-slim

# 安装运行依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopenmpi3 openmpi-bin openmpi-common \
    libhdf5-103-1 zlib1g libpng16-16 vim && \
    rm -rf /var/lib/apt/lists/*

# 拷贝编译好的 chroma 安装树
COPY --from=builder /opt/chroma /opt/chroma

# 版权合规（可选但推荐）
COPY --from=builder /src/chroma/LICENSE /usr/share/doc/chroma/copyright
COPY --from=builder /src/qmp/LICENSE /usr/share/doc/qmp/copyright
COPY --from=builder /src/qdpxx/LICENSE /usr/share/doc/qdpxx/copyright

ENV PATH=/opt/chroma/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/chroma/lib:$LD_LIBRARY_PATH

WORKDIR /opt/chroma
CMD ["chroma", "-version"]
