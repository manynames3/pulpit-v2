from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

REQUEST_COUNTER = Counter(
    "pulpit_ingest_requests_total",
    "Total ingest service requests handled by the FastAPI app.",
)


def create_app() -> FastAPI:
    app = FastAPI(title="pulpit-v2-ingest-service")

    @app.get("/healthz")
    def healthcheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ok", "service": "ingest-service"}

    @app.get("/readyz")
    def readycheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ready", "service": "ingest-service"}

    @app.get("/metrics")
    def metrics() -> Response:
        return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

    return app
