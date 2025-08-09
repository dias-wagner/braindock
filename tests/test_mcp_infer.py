from fastapi.testclient import TestClient

from server.main import app


client = TestClient(app)


def test_mcp_infer_echoes_and_updates_history():
    payload = {
        "session_id": "user-123",
        "mcp_input": {"text": "Hello"},
        "mcp_state": {"history": []},
    }
    res = client.post("/mcp/infer", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["session_id"] == "user-123"
    assert data["mcp_output"] == "Echo: Hello"
    history = data["mcp_state"]["history"]
    assert len(history) == 2
    assert history[0]["role"] == "user" and history[0]["content"] == "Hello"
    assert history[1]["role"] == "assistant" and history[1]["content"] == "Echo: Hello"


def test_mcp_infer_validation_error_on_empty_text():
    payload = {
        "session_id": "user-123",
        "mcp_input": {"text": ""},
        "mcp_state": {"history": []},
    }
    res = client.post("/mcp/infer", json=payload)
    assert res.status_code == 422


