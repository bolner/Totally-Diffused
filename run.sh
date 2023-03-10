#!/usr/bin/env bash

BASE_DIR=/var/totally-diffused
WUI_DIR=${BASE_DIR}/stable-diffusion-webui
PACK_DIR=${WUI_DIR}/venv/lib/python3.9/site-packages

docker exec --user $(whoami) -it totally-diffused /bin/bash -c \
    "cd /var/totally-diffused/stable-diffusion-webui \
    && export LD_LIBRARY_PATH=${PACK_DIR}/tensorrt/:/usr/local/cuda-11.7/targets/x86_64-linux/lib/:\${LD_LIBRARY_PATH}
    ./webui.sh --listen --enable-insecure-extension-access --xformers"
