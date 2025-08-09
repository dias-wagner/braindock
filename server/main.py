from typing import List, Literal

from fastapi import FastAPI
from pydantic import BaseModel, Field


app = FastAPI(title="BrainDock MCP Server", version="0.1.0")


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


class MCPInferResponse(BaseModel):
    session_id: str
    mcp_output: str
    mcp_state: MCPState


@app.post("/mcp/infer", response_model=MCPInferResponse)
def mcp_infer(req: MCPInferRequest) -> MCPInferResponse:
    user_message = MCPMessage(role="user", content=req.mcp_input.text)
    # Mock assistant reply for Phase 1.2
    assistant_reply_text = f"Echo: {req.mcp_input.text}"
    assistant_message = MCPMessage(role="assistant", content=assistant_reply_text)

    updated_history: List[MCPMessage] = [*req.mcp_state.history, user_message, assistant_message]
    return MCPInferResponse(
        session_id=req.session_id,
        mcp_output=assistant_reply_text,
        mcp_state=MCPState(history=updated_history),
    )

