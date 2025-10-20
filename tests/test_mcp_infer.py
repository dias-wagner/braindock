import os
from fastapi.testclient import TestClient

from server.main import app


client = TestClient(app)


def test_mcp_infer_echoes_and_updates_history():
    """Test that MCP endpoint works with default echo mode."""
    payload = {
        "session_id": "user-123",
        "mcp_input": {"text": "Hello"},
        "mcp_state": {"history": []},
    }
    res = client.post("/mcp/infer", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["session_id"] == "user-123"
    assert data["mcp_output"]["text"] == "Echo: Hello"
    history = data["mcp_state"]["history"]
    assert len(history) == 2
    assert history[0]["role"] == "user" and history[0]["content"] == "Hello"
    assert history[1]["role"] == "assistant" and history[1]["content"] == "Echo: Hello"


def test_mcp_infer_with_template_mode():
    """Test MCP endpoint with template mode."""
    # Create a new app instance with template mode
    from server.main import get_llm_adapter
    from server.llm import MockLLMAdapter
    
    # Temporarily override the adapter
    original_adapter = app.state.llm_adapter if hasattr(app.state, 'llm_adapter') else None
    app.state.llm_adapter = MockLLMAdapter(mode="template")
    
    try:
        payload = {
            "session_id": "user-456",
            "mcp_input": {"text": "Test message"},
            "mcp_state": {"history": []},
        }
        res = client.post("/mcp/infer", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert "I'm a mock LLM" in data["mcp_output"]["text"]
        assert "Test message" in data["mcp_output"]["text"]
    finally:
        # Restore original adapter
        if original_adapter:
            app.state.llm_adapter = original_adapter
        elif hasattr(app.state, 'llm_adapter'):
            delattr(app.state, 'llm_adapter')


def test_mcp_infer_with_history():
    """Test that MCP endpoint properly handles conversation history."""
    payload = {
        "session_id": "user-789",
        "mcp_input": {"text": "Second message"},
        "mcp_state": {
            "history": [
                {"role": "user", "content": "First message"},
                {"role": "assistant", "content": "Echo: First message"}
            ]
        },
    }
    res = client.post("/mcp/infer", json=payload)
    assert res.status_code == 200
    data = res.json()
    history = data["mcp_state"]["history"]
    assert len(history) == 4
    assert history[0]["role"] == "user" and history[0]["content"] == "First message"
    assert history[1]["role"] == "assistant" and history[1]["content"] == "Echo: First message"
    assert history[2]["role"] == "user" and history[2]["content"] == "Second message"
    assert "Second message" in history[3]["content"]


def test_mcp_infer_validation_error_on_empty_text():
    """Test validation error for empty input text."""
    payload = {
        "session_id": "user-123",
        "mcp_input": {"text": ""},
        "mcp_state": {"history": []},
    }
    res = client.post("/mcp/infer", json=payload)
    assert res.status_code == 422

