Run GPT-J-6B model (text generation open source GPT-3 analog) for inference on server with GPU using zero-dependency Docker image. 

First script loads model into video RAM (can take several minutes) and then runs internal HTTP server which is listening on 8080.

You can run this image only on instance with 12 GB Video memory and Linux (e.g. Ubuntu) with Docker installed. 

Server machine should have 

1. Nvidia Drivers

E.g. for Ubuntu 20.04
```
apt purge *nvidia*
apt autoremove
add-apt-repository ppa:graphics-drivers/ppa
apt update
apt install -y ubuntu-drivers-common
ubuntu-drivers autoinstall
```

> Note: Nvidia drivers installation process might be quite challenging, e.g. removing some divers might be required sudo dpkg-divert --remove "/usr/lib/x86_64-linux-gnu/libGL.so.1"

3. Docker host with NVIDIA Container Toolkit installed, here is how to install it on Ubuntu:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

apt update && apt upgrade && apt remove -y docker-ce containerd.io
apt install -y nvidia-docker2
curl https://get.docker.com | sh && systemctl --now restart docker
```

If you are using docker.io from repositories, you will get `docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]]`

Docker command to run image:

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

