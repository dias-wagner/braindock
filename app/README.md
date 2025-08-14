# BrainDock Android Client

A Flutter-based Android app that serves as an MCP (Model Context Protocol) client for communicating with the local BrainDock MCP server.

## Features

- **Chat Interface**: Modern, responsive chat UI for interacting with the MCP server
- **Session Management**: Maintains conversation context across messages
- **Connection Testing**: Built-in connection test to verify MCP server availability
- **Error Handling**: Graceful error handling and user feedback
- **Cross-Platform**: Built with Flutter for Android, iOS, and Web support

## Architecture

```
[BrainDock Android App (Flutter)]
  |
  | HTTP (MCP protocol)
  ▼
[Local MCP Server (FastAPI on localhost:8000)]
  |
  | HTTPS/HTTP
  ▼
[Remote LLM API (OpenAI, Claude, etc.)]
```

## Project Structure

```
app/
├── lib/
│   ├── models/
│   │   ├── mcp_models.dart          # MCP data models
│   │   └── mcp_models.g.dart        # Generated JSON serialization
│   ├── services/
│   │   └── mcp_service.dart         # HTTP client for MCP server
│   ├── providers/
│   │   └── chat_provider.dart       # State management
│   ├── screens/
│   │   └── chat_screen.dart         # Main chat UI
│   └── main.dart                    # App entry point
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Dependencies

- **http**: HTTP client for communicating with MCP server
- **provider**: State management
- **json_annotation/json_serializable**: JSON serialization for MCP models

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Version 3.3.10 or compatible
2. **MCP Server**: BrainDock MCP server running on localhost:8000

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate JSON serialization code:
   ```bash
   flutter packages pub run build_runner build
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Start the MCP Server**: Ensure the BrainDock MCP server is running on localhost:8000
2. **Test Connection**: Use the WiFi icon in the app bar to test server connectivity (tests `/healthz` endpoint)
3. **Start Chatting**: Type messages in the input field and press send
4. **Clear Chat**: Use the refresh icon to clear conversation history

## Development

### Building for Different Platforms

- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

### Code Generation

After modifying the MCP models, regenerate the JSON serialization code:
```bash
flutter packages pub run build_runner build
```

## Phase 2.1 Status: ✅ Complete

This phase includes:
- ✅ Flutter project setup with proper dependencies
- ✅ MCP data models with JSON serialization
- ✅ HTTP service for MCP server communication
- ✅ State management with Provider
- ✅ Modern chat UI with error handling
- ✅ Connection testing functionality
- ✅ Cross-platform compilation support

## Next Steps (Phase 2.2)

- HTTP client integration testing
- End-to-end communication with MCP server
- UI polish and additional features

## Troubleshooting

### Common Issues

1. **Connection Failed**: Ensure MCP server is running on localhost:8000
   - The app tests connectivity using the `/healthz` endpoint
   - Verify with: `curl http://127.0.0.1:8000/healthz`
2. **Build Errors**: Run `flutter clean` and `flutter pub get`
3. **JSON Generation**: Run `flutter packages pub run build_runner build`

### Debug Mode

Run with verbose logging:
```bash
flutter run --verbose
```
