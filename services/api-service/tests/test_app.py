from fastapi.testclient import TestClient

from src import app as app_module


client = TestClient(app_module.create_app())


def test_root() -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "api-service"


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


def test_catalog_proxies_query_service(monkeypatch) -> None:
    def fake_proxy(method, url, *, headers=None, json_body=None):
        assert method == "GET"
        assert url == f"{app_module.QUERY_UPSTREAM_URL}/catalog"
        assert headers == {"Content-Type": "application/json", "Authorization": "Bearer test"}
        assert json_body is None
        return 200, {"sermons": [{"title": "Test"}]}

    monkeypatch.setattr(app_module, "proxy_json_request", fake_proxy)
    response = client.get("/catalog", headers={"Authorization": "Bearer test"})

    assert response.status_code == 200
    assert response.json()["sermons"][0]["title"] == "Test"


def test_query_proxies_query_service(monkeypatch) -> None:
    def fake_proxy(method, url, *, headers=None, json_body=None):
        assert method == "POST"
        assert url == f"{app_module.QUERY_UPSTREAM_URL}/query"
        assert headers == {"Content-Type": "application/json", "Authorization": "Bearer test"}
        assert json_body == {"question": "grace", "preferredLanguage": "en"}
        return 200, {"answer": "Based on the archive...", "sources": []}

    monkeypatch.setattr(app_module, "proxy_json_request", fake_proxy)
    response = client.post(
        "/query",
        headers={"Authorization": "Bearer test"},
        json={"question": "grace", "preferredLanguage": "en"},
    )

    assert response.status_code == 200
    assert response.json()["answer"] == "Based on the archive..."
