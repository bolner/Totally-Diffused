FROM debian:11.6
USER root

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y curl ca-certificates openssl net-tools \
    python3-dev git gnupg wget locales nano vim mc zip unzip jq \
    python3 python3-venv procps software-properties-common \
    screen

ARG CUDA_DEB=cuda-repo-debian11-11-7-local_11.7.0-515.43.04-1_amd64.deb
COPY install/${CUDA_DEB} /root/${CUDA_DEB}
RUN cd /root \
    && dpkg -i ${CUDA_DEB} \
    && cp /var/cuda-repo-debian11-11-7-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
    && add-apt-repository contrib \
    && apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cuda
RUN rm /root/${CUDA_DEB}

#################################################################
# Configure
#################################################################
VOLUME ["/var/totally-diffused"]
WORKDIR /var/totally-diffused
EXPOSE 7860

ENTRYPOINT ["tail", "-f", "/dev/null"]
