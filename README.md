# Current version: [2023-06-05](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/baf6946e06249c5af9851c60171692c44ef633e0)

Debian/NVIDIA Docker container for [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)'s Stable Diffusion application. Because updating old versions is impossible due to the Python dependency hell and the badly implemented virtual environment feature.

There are no error messages at startup. By default the application listens on port 7860, bound to all interfaces (0.0.0.0). You can avoid that by using the `./safe_run.sh` script.

# Installation

1. Download and install this 11.7 CUDA driver on the host mashine. If you have newer version installed, then downgrade, because 11.7 is currently the only version which is supported by most libraries involved. Execute as root: (Only if your host is also a Debian, otherwise search for your own version.)
```
# wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda-repo-debian11-11-7-local_11.7.0-515.43.04-1_amd64.deb
# dpkg -i cuda-repo-debian11-11-7-local_11.7.0-515.43.04-1_amd64.deb
# cp /var/cuda-repo-debian11-11-7-local/cuda-*-keyring.gpg /usr/share/keyrings/
# add-apt-repository contrib
# apt-get update
# apt-get install cuda
```

Do not delete the `.deb` file yet, because it can be used for the guest install too. This is examplained later.

2. Now install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html), as it is described on the linked website.

3. Clone this repository into a folder, and make sure that the files are owned by a non-root user.
```
git clone https://github.com/bolner/Totally-Diffused.git
```

4. To avoid downloading the CUDA 11.7 driver again, create an `install` folder in the same directory as where this README file is located, and copy the `cuda-repo-debian11-11-7-local_11.7.0-515.43.04-1_amd64.deb` file there. (If you skip this, then it will be downloaded automatically.)

5. Then build the image, create the container and start the application with:
```
$ ./build.sh
$ ./run.sh
```

# Management

The project folder is shared with the guest, which allows easy access to models or training datasets. It is mapped to `/var/totally-diffused` inside the container. The AUTOMATIC1111 WebUI is also placed inside the project folder after installed, at `/var/totally-diffused/stable-diffusion-webui`.

The container is always running. You can stop and start it with:
```
docker container stop totally-diffused
docker container start totally-diffused
```

When it is running, you can:
- Start the UI: `./run.sh`
- Start the UI without `--listen` and `--enable-insecure-extension-access`: `./safe_run.sh`
- Login as non-root: `./login.sh`
- Login as root: `./root_login.sh`
- Delete the totally-diffused image, the container and do a global prune that deletes unused images:

    `./cleanup.sh`

## About screen

If you execute the `./run.sh` inside a `screen`, then you can disconnect and re-connect to it anytime, letting it running in the background.

Just execute `apt-get install screen` as root to install that program, and start a new session with the `screen` command as the non-root user before executing `./run.sh`.

## Updating the AUTOMATIC1111 web UI

The GIT repository is checked out in detached HEAD state in order to only clone a specific version that is tested.
If you would like to update AUTOMATIC1111 web UI to the newest version, then:

- Enter the `stable-diffusion-webui` folder, and:
    ```
    git checkout master
    git pull
    ```
