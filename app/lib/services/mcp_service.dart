import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import '../models/mcp_models.dart';

class MCPService {
  static final String _baseUrl = Platform.isLinux
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';
  static const String _endpoint = '/mcp/infer';
  final http.Client client;

  MCPService({http.Client? client}) : client = client ?? http.Client();

  /// Send a message to the local MCP server
  Future<MCPResponse> sendMessage({
    required String sessionId,
    required String message,
    required List<MCPMessage> history,
  }) async {
    final url = Uri.parse('$_baseUrl$_endpoint');
    try {
      final request = MCPRequest(
        sessionId: sessionId,
        mcpInput: MCPInput(text: message),
        mcpState: MCPState(history: history),
      );

      final response = await retry(
        () => client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 10)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
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
    final url = Uri.parse('$_baseUrl/healthz');
    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
