import pytest
from server.llm import MockLLMAdapter


class TestMockLLMAdapter:
    """Test the mock LLM adapter implementation."""
    
    def test_echo_mode(self):
        """Test echo mode returns input with 'Echo:' prefix."""
        adapter = MockLLMAdapter(mode="echo")
        messages = [{"role": "user", "content": "Hello world"}]
        
        import asyncio
        response = asyncio.run(adapter.infer(messages))
        assert response == "Echo: Hello world"
    
    def test_template_mode(self):
        """Test template mode returns structured response."""
        adapter = MockLLMAdapter(mode="template")
        messages = [{"role": "user", "content": "Test message"}]
        
        import asyncio
        response = asyncio.run(adapter.infer(messages))
        assert "I'm a mock LLM" in response
        assert "Test message" in response
    
    def test_random_mode(self):
        """Test random mode returns one of predefined responses."""
        adapter = MockLLMAdapter(mode="random")
        messages = [{"role": "user", "content": "Anything"}]
        
        import asyncio
        response = asyncio.run(adapter.infer(messages))
        expected_responses = [
            "That's an interesting point!",
            "I understand what you're saying.",
            "Let me think about that...",
            "Thanks for sharing that with me.",
            "I appreciate your input."
        ]
        assert response in expected_responses
    
    def test_empty_messages(self):
        """Test handling of empty messages list."""
        adapter = MockLLMAdapter()
        
        import asyncio
        response = asyncio.run(adapter.infer([]))
        assert response == "No messages provided."
    
    def test_multiple_messages(self):
        """Test that adapter uses the last message."""
        adapter = MockLLMAdapter(mode="echo")
        messages = [
            {"role": "user", "content": "First message"},
            {"role": "assistant", "content": "Assistant response"},
            {"role": "user", "content": "Last message"}
        ]
        
        import asyncio
        response = asyncio.run(adapter.infer(messages))
        assert response == "Echo: Last message"
    
    def test_is_available(self):
        """Test that mock adapter is always available."""
        adapter = MockLLMAdapter()
        assert adapter.is_available() is True
    
    def test_invalid_mode_fallback(self):
        """Test fallback for invalid mode."""
        adapter = MockLLMAdapter(mode="invalid_mode")
        messages = [{"role": "user", "content": "Test"}]
        
        import asyncio
        response = asyncio.run(adapter.infer(messages))
        assert "Mock response to: Test" in response
