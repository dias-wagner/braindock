import os
from typing import List, Literal

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from .llm import MockLLMAdapter

app = FastAPI(title="BrainDock MCP Server", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify your app's origin
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# ==== LLM Adapter Setup (Phase 1.3) ====
def get_llm_adapter():
    """Get configured LLM adapter based on environment."""
    # For Phase 1.3, always use mock adapter
    # Future: check for OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.
    mock_mode = os.getenv("MOCK_LLM_MODE", "echo")
    return MockLLMAdapter(mode=mock_mode)

@app.on_event("startup")
async def startup_event():
    """Initialize LLM adapter on startup."""
    app.state.llm_adapter = get_llm_adapter()


@app.get("/healthz")
def read_health() -> dict:
    return {"status": "ok"}


@app.get("/")
def read_root() -> dict:
    return {"name": "braindock", "version": "0.1.0"}


# ==== MCP models and endpoint (Phase 1.2) ====

class MCPMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class MCPInput(BaseModel):
    text: str = Field(..., min_length=1)


class MCPState(BaseModel):
    history: List[MCPMessage] = Field(default_factory=list)


class MCPInferRequest(BaseModel):
    session_id: str = Field(..., min_length=1)
    mcp_input: MCPInput
    mcp_state: MCPState



class MCPOutput(BaseModel):
    text: str


class MCPInferResponse(BaseModel):
    session_id: str
    mcp_output: MCPOutput
    mcp_state: MCPState


@app.post("/mcp/infer", response_model=MCPInferResponse)
async def mcp_infer(req: MCPInferRequest) -> MCPInferResponse:
    user_message = MCPMessage(role="user", content=req.mcp_input.text)

    # Convert history to format expected by LLM adapter
    messages = [{"role": msg.role, "content": msg.content} for msg in req.mcp_state.history]
    messages.append({"role": "user", "content": req.mcp_input.text})

    # Get response from LLM adapter (Phase 1.3)
    llm_adapter = getattr(app.state, 'llm_adapter', None)
    if llm_adapter and llm_adapter.is_available():
        assistant_reply_text = await llm_adapter.infer(messages)
    else:
        # Fallback to simple echo if adapter unavailable
        assistant_reply_text = f"Echo: {req.mcp_input.text}"

    assistant_message = MCPMessage(role="assistant", content=assistant_reply_text)
    updated_history: List[MCPMessage] = [*req.mcp_state.history, user_message, assistant_message]

    return MCPInferResponse(
        session_id=req.session_id,
        mcp_output=MCPOutput(text=assistant_reply_text),
        mcp_state=MCPState(history=updated_history),
    )


