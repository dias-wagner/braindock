from abc import ABC, abstractmethod
from typing import List

from pydantic import BaseModel


class LLMAdapter(ABC):
    """Abstract base class for LLM adapters."""
    
    @abstractmethod
    async def infer(self, messages: List[dict], **kwargs) -> str:
        """
        Send messages to LLM and return response.
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            **kwargs: Additional parameters for the LLM call
            
        Returns:
            LLM response as string
        """
        pass
    
    @abstractmethod
    def is_available(self) -> bool:
        """
        Check if the LLM adapter is available/configured.
        
        Returns:
            True if adapter can be used
        """
        pass
