from pydantic_settings import BaseSettings


class Config(BaseSettings):
    cehub_api_host: str = "http://services.cehub.syngenta-ais.com/api"
    cehub_api_key: str = "ba05eac8-de9a-4eda-b873-b779f531b5d2"

    meteoblue_api_host: str = "http://my.meteoblue.com/dataset"
    meteoblue_api_key: str = "b177nablq8f"


config = Config()
