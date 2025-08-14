# 【docker build --no-cache --tag my_image:2.0.1 .】在Dockfile檔案所在目錄執行此指令
# 【docker build --no-cache --tag my_image:2.0.1 --file elvisdocker .】在elvisdocker檔案所在目錄執行此指令
# 【docker build --no-cache --tag my_image:2.0.1 --build-arg VIRTUAL_ENV_NAME=elvis_env --build-arg PYTHON_VERSION=3.10.16 .】
# -----------------------------------------------------------------------------
# FROM ubuntu:24.04
# FROM ubuntu:22.04
# FROM mcr.microsoft.com/devcontainers/base:ubuntu
FROM python:slim

LABEL maintainer=trader.elvis.chuang@gmail.com

# 以帳戶root來安裝
USER root

# 1️⃣ 選取miniconda安裝包
# Set environment variables for Miniconda installation
# Adjust version as needed
# 這些特定版本存放在 https://repo.anaconda.com/miniconda/
# 檔名格式：  
#			py310_23、py311_23、py313_23.... 
#			==> python 3.10 2023 build
#
# ARG MINICONDA_VERSION="py310_23.11.0-2" 
ARG MINICONDA_VERSION="py310_25.3.1-1"

ARG PYTHON_PKG_DIR="python3.10"
ARG CONDA_DIR="/opt/miniconda"

ARG MY_VIRTUAL_ENV_NAME="my_env"
ENV VIRTUAL_ENV_NAME=$MY_VIRTUAL_ENV_NAME

ARG MY_PYTHON_VERSION="3.10.13"
ENV PYTHON_VERSION=$MY_PYTHON_VERSION

ARG MY_MODE="Dev"
ENV APP_MODE=$MY_MODE

ENV PATH="$CONDA_DIR/bin:$PATH"
ENV WORKSPACE_DIR="/workspace"
ENV SOURCE_CODE="/SourceCode"
# 💢補充說明
# 這裡ARG 目的是宣告變數並且給定default值
# 而環境變數則可以引用ARG變數來使用
# 例如：
# ARG MY_VAR="default_value"
# ENV MY_ENV_VAR=$MY_VAR
# 因此，我們可以透過 docker build 或者 docker-compose方式傳遞ARG方式給Dockerfile。
# 注意：
# 在Dockerfile是無法引用外部定義好的 環境變數，必須透過ARG間接方式來導入。

# -----------------------------------------------------------------------------
# 作業系統相關套件安裝
# Install necessary dependencies for Miniconda
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && umask 0002

# -----------------------------------------------------------------------------
# Download and install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda clean --all -f -y

# -----------------------------------------------------------------------------
# Initialize Conda for the current user
# 執行 conda init時候以bash環境來執行，因為conda採用bash方式來執行相關指令。
RUN conda init bash

# -----------------------------------------------------------------------------
# 建置Python虛擬環境
# 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨
# (Optional) Create a Conda environment and install packages
COPY environment.yml /tmp/environment.yml

# 置換YAML檔案裏面的虛擬環境名稱變數
RUN sed -i "s/\${MY_VIRTUAL_ENV_NAME}/${MY_VIRTUAL_ENV_NAME}/g" /tmp/environment.yml
RUN sed -i "s/\${MY_PYTHON_VERSION}/${MY_PYTHON_VERSION}/g" /tmp/environment.yml

# 建立名稱為$VIRTUAL_ENV_NAME的虛擬環境
RUN umask 0002 && \
    conda env create -f /tmp/environment.yml && \
    rm /tmp/environment.yml && \
    conda clean --all -f -y

# 登入系統自動啟動python虛擬環境
RUN echo "conda activate ${MY_VIRTUAL_ENV_NAME}" >> ~/.bashrc
# -----------------------------------------------------------------------------
# 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
ADD ln_src_code.sh .
RUN chmod +x ln_src_code.sh
# RUN echo "source /ln_src_code.sh"  >> ~/.bashrc
# 上面這行程式碼已經被docker-compose.yml中的command:取代了。

# 準備 Source code
WORKDIR $SOURCE_CODE
ADD ./.devcontainer/ ./.devcontainer
ADD ./vnpy_src/ ./vnpy_src
ADD docker-compose.yml \
    Dockerfile \
    environment.yml \
    pcc.sh \
    main.py \
    ./
# -----------------------------------------------------------------------------
WORKDIR $WORKSPACE_DIR

# -----------------------------------------------------------------------------
# Set the default shell to bash and activate the base environment
# 這是一個JSON陣列，每一個元素都是 參數，所以
# "/bin/bash" ==> 使用的shell是bash，而不是sh
# "-lc" 
# "-l"	
# ==> 代表 "login shell"。這個參數會強制 bash 讀取並執行
# ==> 像 /etc/profile、~/.bash_profile、~/.bashrc 等啟動腳本。
# ==> 這對於 Conda 的 conda init 所產生的配置來說至關重要，因為它通常就是寫在這些檔案中。
# "-c"	
# ==> 代表 "command"。
# ==> 這個參數會讓 bash 執行後續的指令，然後立即終止。
# ==> 例如，RUN 指令後面接的字串就是執行 bash -c <你的指令>。
SHELL ["/bin/bash", "-lc"]

# Dockerfile的組成【https://hackmd.io/@tienyulin/docker3】說明
# 💢環境變數與變數【ENV 與 ARG】
# 環境變數ENV為容器內執行的App和Process提供資訊，後續該變數存在於Image之中也會與container一起存在，
# 這與ARG指令是有所不同，ARG所指定的變數只存在於Building Time期間【docker build --build-arg 】
# 而且 ARG設定變數可以使用預設值，如果外部沒有設定ARG 變數會使用預設值，所以ARG與ENV可以互相搭配使用。
# Dockerfile範例：
# ARG TAG=latest            ==>定義變數
# FROM ubuntu:$TAG          ==>引用變數
# LABEL maintainer=ananalogguyinadigitalworld@example.com
# ENV ENVIRONMENT=dev APP_DIR=/usr/local/app/bin
# CMD ["env"]
# 建立iamge指令【docker image build -t env-arg --build-arg TAG=23.10 .】
# 運行image指令【docker container run env-arg】
# .............................................................................
# ENV 格式定義為鍵值對： 
# ENV <key> <value>
# ENV <key>=<value> <key=value> ...
# 範例： ENV PATH $PATH:/usr/local/app/bin/
# 2️⃣使用方式：
# 情況一： 透過 命令列傳入
# 【$ docker run -e KEY=VALUE <Image_ID>】
# ex:〔$ docker run -e DEBUG=1 -e TEST=1 <Image_ID>〕
#
# 情況二： 在Dockerfile中 透過 ENV指令來設定
# FROM busybox
# ENV DEBUG=1
# ENV TEST=1
# CMD ["env"] 
# 然後透過命令列來建立Image與建立container
# $ docker build --tag printenv .
# $ docker run printenv
# 
# 情況三： docker-compose.yml
# (1)我們可以透過【export TAG=1.0】定義環境變數
# 然後在docker-compose.yml中引用該變數
# web:
#   image: "webapp:${TAG}"
# (2)在docker-compose.yml中定義環境變數
# web:
#   image: "webapp"
#   environment:
#     - DEBUG=1
# 	  - TEST=1

