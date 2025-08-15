## BrainDock: MCP Client–Server Architecture for Android with Remote LLM Access

### Overview
BrainDock is a lightweight, modular system that enables an Android app to communicate with a local MCP-compliant server running on the device (or emulator). The local server forwards requests to a remote LLM provider (OpenAI, Anthropic, Mistral, etc.), maintains session context, and returns the response and updated state to the app.

This setup gives you full control over context and memory, lets you swap LLMs freely, and avoids on-device inference for better performance and power use. It runs on Linux, Android (via Termux), and emulator environments.

### Architecture
```
[Android App (Client)]
  |
  | HTTP (MCP protocol)
  ▼
[Local MCP Server (FastAPI on Android/Termux)]
  |
  | HTTPS/HTTP
  ▼
[Remote LLM API (OpenAI / Anthropic / Mistral / Ollama, etc.)]
```

### Components
| Component | Technology Stack | Rationale |
| --- | --- | --- |
| Android MCP Client App | Flutter / Kotlin / React Native | Cross-platform UI with HTTP client, handles local request to server |
| Local MCP Server | Python + FastAPI on Termux (Android) | Lightweight, embeddable, sessionful API that speaks MCP protocol |
| Remote LLM API | OpenAI / Claude / Mistral API (JSON over HTTPS) | Pretrained LLM with inference capabilities |
| Session/Context Manager | In-memory dict or SQLite (future) | Maintains per-session state for MCP |

### Technical Requirements
- MCP-compliant request/response interface
- Android app sends queries to local server
- Local server tracks per-session state/context
- Server forwards stateless LLM calls with session context reconstructed
- LLM response and updated state returned to Android app

#### Non-Functional
- Low latency on Android devices
- Offline operation (except for LLM calls)
- Secure API key handling (remote API)
- Resource-efficient background server on Android

### Key Challenges & Solutions
| Challenge | Risk Level | Solution |
| --- | --- | --- |
| Running Python/HTTP server on Android | Medium | Use Termux + uvicorn; minimal server footprint |
| Persistent context tracking across sessions | Low | In-memory dict; serialize to JSON/SQLite for persistence |
| Secure API key handling | Medium | Store in Termux with restricted permissions; .env or Android keystore |
| Communication app ⇄ local server | Low | Use 127.0.0.1 (or 10.0.2.2 in Android emulator) |
| MCP compliance with evolving spec | Low | Custom adapter that wraps requests/responses in MCP schema |
| LLM rate limits / cost | Medium | Add rate limiting, batching on server side |
| Background process reliability | Medium | Termux wake-lock or app hook (if rooted) |

### MCP Server API Contract
- Endpoint: `POST /mcp/infer`

Request example:
```json
{
  "session_id": "user-123",
  "mcp_input": { "text": "Hello, who are you?" },
  "mcp_state": {
    "history": [
      {"role": "user", "content": "..."},
      {"role": "assistant", "content": "..."}
    ]
  }
}
```

Response example:
```json
{
  "session_id": "user-123",
  "mcp_output": "I’m a helpful assistant.",
  "mcp_state": { "history": ["... full updated history ..."] }
}
```

### Getting Started
This repo targets a phased rollout. You can begin by running a local FastAPI server on Linux, then move to Termux on Android.

#### Prerequisites
- Python 3.10+
- pip / uv
- An account and API key for your chosen LLM provider (e.g., `OPENAI_API_KEY`)

#### Environment variables
Create a `.env` file (or export variables) for remote LLM access:
```
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
MISTRAL_API_KEY=...
```
Only set the providers you intend to use.

#### Setup (venv + requirements) on Linux/Mac
Create and activate a virtual environment, then install dependencies from `requirements.txt`:
```
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

#### Run the local MCP server
Adjust the module path to your actual FastAPI app instance (e.g., `server.main:app`).
```
uvicorn server.main:app --host 127.0.0.1 --port 8000
```

#### Test the endpoint
```
curl -s http://127.0.0.1:8000/mcp/infer \
  -H 'Content-Type: application/json' \
  -d '{
        "session_id": "user-123",
        "mcp_input": {"text": "Hello"},
        "mcp_state": {"history": []}
      }'
```

#### Run tests
With the virtual environment activated:
```
pytest -q
```

### Android App (MCP Client) - Phase 2.1 ✅ Complete

The Android app is built with Flutter and provides a modern chat interface for interacting with the MCP server.

**Features:**
- Modern chat UI with message bubbles
- Session management and context preservation
- Connection testing functionality
- Error handling and user feedback
- Cross-platform support (Android, iOS, Web)

**Setup:**
```bash
cd app
flutter pub get
flutter packages pub run build_runner build
flutter run
```

**Architecture:**
- HTTP client communicates with local MCP server
- Provider pattern for state management
- JSON serialization for MCP protocol messages
- Responsive UI with Material Design 3

**Usage:**
- Point HTTP requests to `http://127.0.0.1:8000/mcp/infer` on device
- In Android emulator, use `http://10.0.2.2:8000/mcp/infer` to reach the host machine
- Test connection using the WiFi icon in the app bar

### Termux on Android
1. Install Termux from a trusted source.
2. Update packages: `pkg update && pkg upgrade`
3. Install Python and git: `pkg install python git`
4. Clone project and install deps: `pip install -r requirements.txt`
5. Copy env template and set keys with restrictive permissions:
   ```
   cp .env.example .env
   chmod 600 .env
   # edit .env to set OPENAI_API_KEY / ANTHROPIC_API_KEY / MISTRAL_API_KEY
   ```
6. Start the server (bind to loopback):
   ```
   uvicorn server.main:app --host 127.0.0.1 --port 8000
   ```
7. Keep the device awake if needed: `termux-wake-lock`

### Session and Context
- The server maintains per-session `history` (user/assistant turns).
- For remote LLM calls, the server reconstructs context from `mcp_state`.
- Future: persist sessions to JSON/SQLite for continuity across restarts.

### Testing Strategy
Unit tests:
- Request/response formatting
- Context merging logic
- LLM response parsing
- Session state management

Integration tests:
- Android client ⇄ Local server
- Local server ⇄ Remote LLM API
- Session continuity across requests

Manual testing:
- Run the server on Linux/Termux
- Use `curl`/`httpie` to exercise `/mcp/infer`
- Use Android emulator pointed at `10.0.2.2`

### Performance Considerations
| Resource | Constraint | Strategy |
| --- | --- | --- |
| CPU (Android) | Light, must stay idle | Avoid heavy computation locally |
| Memory | Must store session | Serialize context when idle |
| Network | Needed for LLM | Retries and exponential backoff |
| Battery | Background-friendly | Run only on demand |

### Security Considerations
- Do not store API keys in plaintext inside the Android app.
- Validate and sanitize all input (even from localhost).
- Strong per-session isolation to prevent cross-user leakage.
- Bind server to `127.0.0.1` only; avoid exposing externally.

### Roadmap (Phases)
| Phase | Milestone | Deliverable |
| --- | --- | --- |
| 1 | Linux MCP server prototype | FastAPI + mock OpenAI forwarding |
| 1.1 | FastAPI project skeleton | Basic FastAPI server running locally |
| 1.2 | Implement MCP endpoint | `/mcp/infer` endpoint with mock response |
| 1.3 | Integrate mock LLM call | Forward input and return response |
| 1.4 | Unit tests for server logic | Request/response, context handling |
| 2 | Android app (MCP client) | UI + HTTP calls to local server |
| 2.1 | Android app setup | ✅ Flutter/Kotlin scaffold |
| 2.2 | HTTP client integration | App can POST to server |
| 2.3 | Chat UI | Display responses |
| 2.4 | E2E integration | App ⇄ Server |
| 3 | Termux MCP server | Run server natively on Android |
| 3.1 | Termux setup | Documented steps |
| 3.2 | Deploy FastAPI | Server responds on device |
| 3.3 | App connects to Termux | Local communication on device |
| 3.4 | Perf/resource test | Latency, CPU, memory |
| 4 | Session storage & control | Persistent state handling |
| 4.1 | In-memory store | Per-session dict |
| 4.2 | Persistent context | JSON/SQLite |
| 4.3 | Session tests | Continuity and isolation |
| 4.4 | Context UI | View/reset in app |
| 5 | Production | API key mgmt, monitoring, UI polish |
| 5.1 | Secure key storage | Termux/Keystore |
| 5.2 | Monitoring & logging | Request/response logging |
| 5.3 | UI/UX polish | Improved interface |
| 5.4 | Release checklist | Docs, security review, build |

### License
Apache License 2.0. See `LICENSE`.


