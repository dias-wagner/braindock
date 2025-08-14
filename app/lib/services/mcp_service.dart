import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mcp_models.dart';

class MCPService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _endpoint = '/mcp/infer';

  /// Send a message to the local MCP server
  Future<MCPResponse> sendMessage({
    required String sessionId,
    required String message,
    required List<MCPMessage> history,
  }) async {
    try {
      final request = MCPRequest(
        sessionId: sessionId,
        mcpInput: MCPInput(text: message),
        mcpState: MCPState(history: history),
      );

      final response = await http.post(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return MCPResponse.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to send message: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error communicating with MCP server: $e');
    }
  }

  /// Test connection to the MCP server
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/healthz'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
