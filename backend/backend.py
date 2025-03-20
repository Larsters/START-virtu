from fastapi import FastAPI
import uvicorn
import model.llm_wrapper.services.soil_service as soil_service
import model.llm_wrapper.services.current_weather_service as current_weather_service
from dotenv import load_dotenv
import os

app = FastAPI()


@app.get("/getCurrentWeather")
def current_weather(latitude: float, longitude: float):
    return current_weather_service.get_current_weather(latitude, longitude)


@app.get("/getSoilData")
def soil_conditions(latitude: float, longitude: float):
    return soil_service.fetch_soil_data(latitude, longitude)


def serve():
    load_dotenv()
    uvicorn.run("backend:app", host="127.0.0.1", port=8000)


if __name__ == "__backend__":
    serve()
