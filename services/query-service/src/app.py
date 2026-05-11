import os
from typing import Any

import httpx
from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

REQUEST_COUNTER = Counter(
    "pulpit_query_requests_total",
    "Total query service requests handled by the FastAPI app.",
)

QUERY_LATENCY = Histogram(
    "pulpit_query_request_latency_seconds",
    "Request latency for the query service.",
)

UPSTREAM_QUERY_URL = os.environ.get(
    "PULPIT_V1_QUERY_URL",
    "https://6nlf91miid.execute-api.us-east-1.amazonaws.com/dev/query",
)
UPSTREAM_CATALOG_URL = os.environ.get(
    "PULPIT_V1_CATALOG_URL",
    "https://6nlf91miid.execute-api.us-east-1.amazonaws.com/dev/catalog",
)


def build_upstream_headers(request: Request) -> dict[str, str]:
    headers = {"Content-Type": "application/json"}
    authorization = request.headers.get("authorization")
    if authorization:
        headers["Authorization"] = authorization
    return headers


def proxy_json_request(
    method: str,
    url: str,
    *,
    headers: dict[str, str] | None = None,
    json_body: dict[str, Any] | None = None,
) -> tuple[int, dict[str, Any]]:
    with httpx.Client(timeout=60.0) as client:
        response = client.request(method, url, headers=headers, json=json_body)

    try:
        payload = response.json()
    except ValueError:
        payload = {"error": response.text or "Upstream returned a non-JSON response."}

    return response.status_code, payload


def create_app() -> FastAPI:
    app = FastAPI(title="pulpit-v2-query-service")

    @app.get("/")
    def root() -> dict[str, Any]:
        REQUEST_COUNTER.inc()
        return {
            "status": "ok",
            "service": "query-service",
            "routes": ["/healthz", "/readyz", "/metrics", "/catalog", "/query"],
        }

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

    @app.get("/catalog")
    def catalog(request: Request) -> JSONResponse:
        REQUEST_COUNTER.inc()
        with QUERY_LATENCY.time():
            status_code, payload = proxy_json_request(
                "GET",
                UPSTREAM_CATALOG_URL,
                headers=build_upstream_headers(request),
            )
            return JSONResponse(status_code=status_code, content=payload)

    @app.post("/query")
    async def query(request: Request) -> JSONResponse:
        REQUEST_COUNTER.inc()
        body = await request.json()
        with QUERY_LATENCY.time():
            status_code, payload = proxy_json_request(
                "POST",
                UPSTREAM_QUERY_URL,
                headers=build_upstream_headers(request),
                json_body=body,
            )
            return JSONResponse(status_code=status_code, content=payload)

    return app
