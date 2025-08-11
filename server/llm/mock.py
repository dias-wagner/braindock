import os
from typing import List

from .base import LLMAdapter


class MockLLMAdapter(LLMAdapter):
    """Mock LLM adapter for testing and development."""
    
    def __init__(self, mode: str = "echo"):
        """
        Initialize mock adapter.
        
        Args:
            mode: Response mode - "echo", "template", or "random"
        """
        self.mode = mode
    
    async def infer(self, messages: List[dict], **kwargs) -> str:
        """Generate mock response based on mode."""
        if not messages:
            return "No messages provided."
        
        last_message = messages[-1]["content"]
        
        if self.mode == "echo":
            return f"Echo: {last_message}"
        elif self.mode == "template":
            return f"I'm a mock LLM. You said: '{last_message}'. This is a template response."
        elif self.mode == "random":
            responses = [
                "That's an interesting point!",
                "I understand what you're saying.",
                "Let me think about that...",
                "Thanks for sharing that with me.",
                "I appreciate your input."
            ]
            import random
            return random.choice(responses)
        else:
            return f"Mock response to: {last_message}"
    
    def is_available(self) -> bool:
        """Mock adapter is always available."""
        return True
