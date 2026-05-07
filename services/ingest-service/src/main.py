from fastapi import FastAPI

app = FastAPI(title="pulpit-v2-ingest-service")


@app.get("/healthz")
def healthcheck() -> dict[str, str]:
    return {"status": "ok", "service": "ingest-service"}

