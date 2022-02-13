Run GPT-J-6B model (text generation open source GPT-3 analog) for inference on server with GPU using zero-dependency Docker image. 

First script loads model into video RAM (can take several minutes) and then runs internal HTTP server which is listening on 8080.

You can run this image only on instance with 12 GB Video memory and Linux (e.g. Ubuntu) with Docker installed. 

Docker command to run image:

```
docker run -p8080:8080 --gpus all --rm -it devforth/gpt-j-6b-gpu
```

> `--gpus all` passes GPU into docker container, so internal bundled cuda instance will smoothly use it 

> Though for apu we are using async FastAPI web server, calls to model which generate a text are blocking, so you should not expect parallelism from this webserver

Then you can call model by using rest API:


For developemnt clone the repository and run on server:

```
docker run -p8080:8080 --gpus all --rm -it $(docker build -q .)
```

