from fastapi import FastAPI
import uvicorn
from cehub_api import get_current_weather


app = FastAPI()

api_key = "uab1ovjb198baaj"


@app.get("/getCurrentWeather")
def current_weather(longitude, latitude):
    return get_current_weather(longitude, latitude)


def call_llm_agent(longitude, latitude):
    ...


def serve():
    uvicorn.run("backend:app", host="127.0.0.1", port=8000)


if __name__ == "__backend__":
    serve()
