from fastapi import FastAPI
import uvicorn
import model.llm_wrapper.services.soil_service as soil_service
import model.llm_wrapper.services.current_weather_service as current_weather_service
from model.llm_wrapper.domain_logic.risk_stats import get_stats
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = [
    "http://localhost.tiangolo.com",
    "https://localhost.tiangolo.com",
    "http://localhost",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/getCurrentWeather")
def current_weather(latitude: float, longitude: float):
    return current_weather_service.get_current_weather(latitude, longitude)


@app.get("/getSoilData")
def soil_conditions(latitude: float, longitude: float):
    return soil_service.fetch_soil_data(latitude, longitude)


@app.get("/getRiskStats")
def algorithm_statistics(latitude: float, longitude: float, crop: str):
    return get_stats(latitude, longitude, crop)


def serve():
    load_dotenv()
    uvicorn.run("backend:app", host="127.0.0.1", port=8000)


if __name__ == "__backend__":
    serve()
