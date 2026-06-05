from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_root_endpoint_returns_message():

    response = client.get("/")

    assert response.status_code == 200

    body = response.json()

    assert body["status"] == "ok"
    assert "environment" in body
    assert isinstance(body["environment"], str)


def test_health_endpoint_returns_ok_status():

    response = client.get("/health")

    assert response.status_code == 200

    body = response.json()

    assert body["status"] == "ok"
    assert "environment" in body
    assert isinstance(body["environment"], str)


def test_metrics_endpoint_returns_prometheus_text():

    response = client.get("/metrics")

    assert response.status_code == 200

    assert response.headers[
        "content-type"
    ].startswith("text/plain")


def test_metrics_endpoint_contains_counter():

    response = client.get("/metrics")

    assert response.status_code == 200

    assert (
        "app_requests_total"
        in response.text
    )