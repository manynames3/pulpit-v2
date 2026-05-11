import os
from typing import Any

import httpx
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

REQUEST_COUNTER = Counter(
    "pulpit_api_requests_total",
    "Total API service requests handled by the FastAPI app.",
)

QUERY_UPSTREAM_URL = os.environ.get(
    "PULPIT_QUERY_UPSTREAM_URL",
    "http://localhost:8000",
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
    app = FastAPI(title="pulpit-v2-api-service")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/")
    def root() -> dict[str, Any]:
        REQUEST_COUNTER.inc()
        return {
            "status": "ok",
            "service": "api-service",
            "routes": ["/healthz", "/readyz", "/metrics", "/catalog", "/query"],
        }

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

    @app.get("/catalog")
    def catalog(request: Request) -> JSONResponse:
        REQUEST_COUNTER.inc()
        status_code, payload = proxy_json_request(
            "GET",
            f"{QUERY_UPSTREAM_URL}/catalog",
            headers=build_upstream_headers(request),
        )
        return JSONResponse(status_code=status_code, content=payload)

    @app.post("/query")
    async def query(request: Request) -> JSONResponse:
        REQUEST_COUNTER.inc()
        body = await request.json()
        status_code, payload = proxy_json_request(
            "POST",
            f"{QUERY_UPSTREAM_URL}/query",
            headers=build_upstream_headers(request),
            json_body=body,
        )
        return JSONResponse(status_code=status_code, content=payload)

    return app
