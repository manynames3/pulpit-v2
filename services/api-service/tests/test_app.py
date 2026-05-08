from fastapi.testclient import TestClient

from src.app import create_app


client = TestClient(create_app())


def test_healthcheck() -> None:
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json()["service"] == "api-service"


def test_readycheck() -> None:
    response = client.get("/readyz")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_metrics_endpoint() -> None:
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "pulpit_api_requests_total" in response.text
