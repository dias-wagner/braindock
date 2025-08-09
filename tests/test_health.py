from fastapi.testclient import TestClient

from server.main import app


client = TestClient(app)


def test_healthz_ok():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_root_ok():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "braindock"
    assert "version" in data


