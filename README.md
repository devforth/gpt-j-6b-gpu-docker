Run GPT-J-6B model (text generation open source GPT-3 analog) for inference on server with GPU using zero-dependency Docker image. 

First script loads model into video RAM (can take several minutes) and then runs internal HTTP server which is listening on 8080.

# Prerequirements to run GPT-J on GPU

You can run this image only on instance with 16 GB Video memory and Linux (e.g. Ubuntu)

Server machine should have NVIDIA Driver and Docker daemon with NVIDIA Container Toolkit. See below.

> Tested on NVIDIA Titan RTX, NVIDIA Tesla P100, 
> Not supported: NVIDIA RTX 3090, RTX A5000, RTX A6000. Reasone Cuda+PyTorch coombination:
> CUDA capability sm_86 is not supported, PyTorch install supports CUDA capabilities sm_37 sm_50 sm_60 sm_70 (we use latest PyTorch during image build), [match sm_x to video card](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)

## Install Nvidia Drivers

You can skip this step if you already have `nvidia-smi` and it outputs the table with CUDA Version:

``` 
Mon Feb 14 14:28:16 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 510.47.03    Driver Version: 510.47.03    CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
| ...

```

E.g. for Ubuntu 20.04
```
apt purge *nvidia*
apt autoremove
add-apt-repository ppa:graphics-drivers/ppa
apt update
apt install -y ubuntu-drivers-common
ubuntu-drivers autoinstall
```

> Note: Unfortunetely NVIDIA drivers installation process might be quite challenging sometimes, e.g. there might be some known issues https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-390/+bug/1768050/comments/3, Google helps a lot

After installing and rebooting, test it with `nvidia-smi`, you should see table.

## Install Dockerd with NVIDIA Container Toolkit:

How to install it on Ubuntu:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

apt update && apt -y upgrade
curl https://get.docker.com | sh && systemctl --now restart docker 
apt install -y nvidia-docker2
```
And reboot server.

To test that CUDA in Docker works run :

```
docker run --rm --gpus all nvidia/cuda:11.1-base nvidia-smi
```

If all was installed correctly it should show same table as `nvidia-smi` on host.
If you have no NVIDIA Container Toolkit or did not reboot server yet you would get `docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]` 


# Docker command to run image:

```
docker run -p8080:8080 --gpus all --rm -it devforth/gpt-j-6b-gpu
```

> `--gpus all` passes GPU into docker container, so internal bundled cuda instance will smoothly use it 

> Though for apu we are using async FastAPI web server, calls to model which generate a text are blocking, so you should not expect parallelism from this webserver

Then you can call model by using REST API:

```
POST http://yourServerPublicIP:8080/generate/
Content-Type: application/json
Body: 

{
  "text": "Client: Hi, who are you?\nAI: I am Vincent and I am barista!\nClient: What do you do every day?\nAI:",
  "generate_tokens_limit": 40,
  "top_p": 0.7,
  "top_k": 0,
  "temperature":1.0
}
```


For developemnt clone the repository and run on server:

```
docker run -p8080:8080 --gpus all --rm -it $(docker build -q .)
```

