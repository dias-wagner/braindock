from fastapi import FastAPI


app = FastAPI(title="BrainDock MCP Server", version="0.1.0")


@app.get("/healthz")
def read_health() -> dict:
    return {"status": "ok"}


@app.get("/")
def read_root() -> dict:
    return {"name": "braindock", "version": "0.1.0"}


