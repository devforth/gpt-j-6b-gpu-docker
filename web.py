from fastapi import FastAPI
from pydantic import BaseModel
import model

app = FastAPI()

class Input(BaseModel):
    generate_tokens_limit: int = 100
    top_p: float = 0.7
    top_k: int = 0
    temperature: float = 1.0
    text: str


@app.post("/generate/")
async def generate(input: Input):
    # we intentionally make non-await call to model, on GPU implementation it can't be paralelized
    # for parallel generation please check running GPT-J on Google TPU https://github.com/kingoflolz/mesh-transformer-jax
    try:
        output = model.eval(input)
        return {"completion": output}
    except Exception as e:
        return {"error": str(e)}

