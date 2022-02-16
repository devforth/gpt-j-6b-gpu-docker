FROM nvidia/cuda:11.1-base
RUN apt update\
  && apt install -y python3 python3-pip wget git zstd curl\
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y nvidia-cuda-toolkit
RUN wget -c https://mystic.the-eye.eu/public/AI/GPT-J-6B/step_383500_slim.tar.zstd\
  && tar -I zstd -xf step_383500_slim.tar.zstd\
  && rm step_383500_slim.tar.zstd
RUN git clone https://github.com/kingoflolz/mesh-transformer-jax.git
RUN pip3 install -r mesh-transformer-jax/requirements.txt
RUN pip3 install torch mesh-transformer-jax/ jax==0.2.12 jaxlib==0.1.68 -f https://storage.googleapis.com/jax-releases/jax_releases.html
RUN mkdir gpt-j-6B &&\
  curl https://gist.githubusercontent.com/finetuneanon/a55bdb3f5881e361faef0e96e1d41f09/raw/e5a38dad34ff42bbad188afd5e4fdb2ab2eacb6d/gpt-j-6b.json > gpt-j-6B/config.json
COPY converttotorch.py ./
RUN python3 converttotorch.py
RUN pip3 install fastapi pydantic uvicorn && pip3 install numpy --upgrade && pip3 install git+https://github.com/finetuneanon/transformers@gpt-j
COPY web.py ./
COPY model.py ./
CMD uvicorn web:app --port 8080 --host 0.0.0.0


