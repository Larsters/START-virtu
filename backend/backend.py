from fastapi import FastAPI
import uvicorn

app = FastAPI()


@app.get("/")
def index():
    return {"message": "Hello, World"}


def serve():
    uvicorn.run("backend:app", host="127.0.0.1", port=8000)


if __name__ == "__backend__":
    serve()
