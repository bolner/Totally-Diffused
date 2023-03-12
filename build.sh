#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
    >&2 echo "This script should not be run as root."
    exit 1
fi

if [[ `which nvcc` == "" ]]; then
    >&2 echo "Please install version 11.7 of the CUDA driver."
    exit 1
fi

REQUIRED_VERSION="11.7"
CUDA_VERSION=$(nvcc --version | sed -n 's/^.*release \([0-9]\+\.[0-9]\+\).*$/\1/p')

if [[ "${CUDA_VERSION}" != "${REQUIRED_VERSION}" ]]; then
    >&2 echo "Invalid version of the CUDA driver is installed. Please install version '${REQUIRED_VERSION}'."
    exit 1
fi

if [[ `which nvidia-container-toolkit` == "" ]]; then
    >&2 echo "Please install 'nvidia-container-toolkit'."
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${DIR}

BASE_DIR=/var/totally-diffused
WUI_DIR=${BASE_DIR}/stable-diffusion-webui
PACK_DIR=${WUI_DIR}/venv/lib/python3.9/site-packages

###################################################
# Download CUDA installer if not present
###################################################
FILE="cuda-repo-debian11-11-7-local_11.7.0-515.43.04-1_amd64.deb"
URL_BASE="https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers"

if [ ! -f "install/${FILE}" ]; then
    if [ ! -f "install" ]; then
        mkdir install
    fi

    cd install
    wget ${URL_BASE}/${FILE}
    cd ${DIR}
fi

###################################################
# Build image
###################################################
docker build --tag totally-diffused -f Dockerfile ./

###################################################
# Create container and configure it
###################################################
docker run -d -h totally-diffused --gpus all --restart unless-stopped \
    -p 7860:7860 -v "${DIR}:${BASE_DIR}" \
    --name totally-diffused totally-diffused

docker exec --user root -it totally-diffused bash -c \
    "useradd -m -s /bin/bash -u $(id -u) $(whoami)"

###################################################
# stable-diffusion-webui
###################################################
if [ ! -f "stable-diffusion-webui/launch.py" ]; then
    docker exec --user $(whoami) -it totally-diffused bash -c \
        "mkdir ${WUI_DIR} 2>/dev/null \
        ; cd ${WUI_DIR} \
        && git init \
        && git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui.git \
        && git fetch --depth 1 origin 27e319dc4f09a2f040043948e5c52965976f8491 \
        && git checkout FETCH_HEAD"
fi

docker exec --user $(whoami) -it totally-diffused bash -c \
    "cd ${WUI_DIR} && ./webui.sh --exit"

###################################################
# DreamBooth
###################################################

# xformers 0.0.17.dev464 = github b89a4935c7dec6ecbfc565002c6f90189fafea8b
# dreambooth = github 5be87ba63f62c228cf135425e21577f70c4e3351
# tensorrt 8.5.3.1 = github b0c259a749aab1486ed3b4458e7176555b003497

docker exec --user $(whoami) -it totally-diffused bash -c \
    "cd ${WUI_DIR} \
    && source ./venv/bin/activate \
    ; pip install --no-input xformers==0.0.17.dev464 \
    ; pip install --no-input tensorrt==8.5.3.1 \
    ; ln -s ${PACK_DIR}/tensorrt/libnvinfer.so.8 \
       ${PACK_DIR}/tensorrt/libnvinfer.so.7 2>/dev/null \
    ; ln -s ${PACK_DIR}/tensorrt/libnvinfer_plugin.so.8 \
       ${PACK_DIR}/tensorrt/libnvinfer_plugin.so.7 2>/dev/null"

docker exec --user $(whoami) -it totally-diffused bash -c \
    "printf '\n\nexport LD_LIBRARY_PATH=${PACK_DIR}/tensorrt/:/usr/local/cuda-11.7/targets/x86_64-linux/lib/\n' >> ~/.bashrc"

###################################################
# other
###################################################
docker exec --user $(whoami) -it totally-diffused bash -c \
    "printf 'shell /bin/bash\n' > ~/.screenrc"
