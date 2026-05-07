from fastapi import FastAPI

app = FastAPI(title="pulpit-v2-api-service")


@app.get("/healthz")
def healthcheck() -> dict[str, str]:
    return {"status": "ok", "service": "api-service"}

