from fastapi import FastAPI, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

REQUEST_COUNTER = Counter(
    "pulpit_query_requests_total",
    "Total query service requests handled by the FastAPI app.",
)

QUERY_LATENCY = Histogram(
    "pulpit_query_request_latency_seconds",
    "Request latency for the query service.",
)


def create_app() -> FastAPI:
    app = FastAPI(title="pulpit-v2-query-service")

    @app.get("/healthz")
    def healthcheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ok", "service": "query-service"}

    @app.get("/readyz")
    def readycheck() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        return {"status": "ready", "service": "query-service"}

    @app.get("/metrics")
    def metrics() -> Response:
        return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

    @app.get("/query/example")
    def example_query() -> dict[str, str]:
        REQUEST_COUNTER.inc()
        with QUERY_LATENCY.time():
            return {"status": "placeholder", "service": "query-service"}

    return app
