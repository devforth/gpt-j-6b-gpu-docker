from fastapi import FastAPI
from pydantic import BaseModel
import model

app = FastAPI()

class Input(BaseModel):
    max_length: int = 100
    top_p: float = 0.7
    top_k: float = 0
    temperature: float = 1.0
    text: str


@app.post("/generate/")
async def generate(input: Input):
    # we intentionally my non-await call to model, on GPU implementation it can't be paralelized
    # for parallel generation please check running GPT-J on Google TPU https://github.com/kingoflolz/mesh-transformer-jax
    output = model.eval(input)
    return {"completion": output}

