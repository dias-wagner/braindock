import 'package:flutter/foundation.dart';
import '../models/mcp_models.dart';
import '../services/mcp_service.dart';


class ChatProvider with ChangeNotifier {
  final MCPService _mcpService;
  
  List<MCPMessage> _messages = [];
  bool _isLoading = false;
  String _error = '';
  String _sessionId = 'default-session';

  List<MCPMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get sessionId => _sessionId;

  ChatProvider({MCPService? mcpService}) : _mcpService = mcpService ?? MCPService();

  factory ChatProvider.withService(MCPService service) => ChatProvider(mcpService: service);

  /// Send a message to the MCP server
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Send to MCP server
      final response = await _mcpService.sendMessage(
        sessionId: _sessionId,
        message: message,
        history: _messages,
      );

      // Always update with server's history
      if (response.mcpState.history.isNotEmpty) {
        _messages = response.mcpState.history;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the chat history
  void clearChat() {
    _messages.clear();
    _error = '';
    notifyListeners();
  }

  /// Test connection to the MCP server
  Future<bool> testConnection() async {
    return await _mcpService.testConnection();
  }

  /// Set a new session ID
  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    notifyListeners();
  }
}
