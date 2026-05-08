from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

REQUEST_COUNTER = Counter(
    "pulpit_api_requests_total",
    "Total API service requests handled by the FastAPI app.",
)


def create_app() -> FastAPI:
    app = FastAPI(title="pulpit-v2-api-service")

    @app.get("/healthz")
    def healthcheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ok", "service": "api-service"}

    @app.get("/readyz")
    def readycheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ready", "service": "api-service"}

    @app.get("/metrics")
    def metrics() -> Response:
        return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

    return app
