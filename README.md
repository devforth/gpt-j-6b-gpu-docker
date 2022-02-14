Run GPT-J-6B model (text generation open source GPT-3 analog) for inference on server with GPU using zero-dependency Docker image. 

First script loads model into video RAM (can take several minutes) and then runs internal HTTP server which is listening on 8080.

# Prerequirements

You can run this image only on instance with 12 GB Video memory and Linux (e.g. Ubuntu) with Docker installed. 

Server machine should have Nvidia Drivers and Docker daemon with NVIDIA Container Toolkit

## Install Nvidia Drivers

E.g. for Ubuntu 20.04
```
apt purge *nvidia*
apt autoremove
add-apt-repository ppa:graphics-drivers/ppa
apt update
apt install -y ubuntu-drivers-common
ubuntu-drivers autoinstall
```

> Note: Unfortunetely Nvidia drivers installation process might be quite challenging, e.g. there might be some known issues https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-390/+bug/1768050/comments/3

After installing and rebooting, to test all is ok please run `nvidia-smi`:
``` 
Mon Feb 14 14:28:16 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 510.47.03    Driver Version: 510.47.03    CUDA Version: 11.6     |
|-------------------------------+----------------------+----------------------+
```

## Dockerd with NVIDIA Container Toolkit installed:

How to install it on Ubuntu:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

apt update && apt upgrade && apt remove -y docker-ce containerd.io 
curl https://get.docker.com | sh && systemctl --now restart docker 
apt install -y nvidia-docker2
```

To test that CUDA in docker works run :

```
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

If all was installed correctly it should show same pseudo-table as in previous section. If you have no NVIDIA Container Toolkit you will get `docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]` 


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
  "max_length": 40,
  "top_p": 0.7,
  "top_k": 0,
  "temperature":1.0
}
```


For developemnt clone the repository and run on server:

```
docker run -p8080:8080 --gpus all --rm -it $(docker build -q .)
```

