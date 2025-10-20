import 'dart:io';
import 'dart:convert';
import 'package:braindock_client/models/mcp_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:braindock_client/services/mcp_service.dart';

void main() {
  group('MCPService', () {
    test('sendMessage retries on SocketException and succeeds', () async {
      int attempts = 0;
      final mockClient = MockClient((request) async {
        attempts++;
        if (attempts < 3) {
          throw const SocketException('Test SocketException');
        }
        final response = {
          "session_id": "test-session",
          "mcp_output": {"text": "Hello"},
          "mcp_state": {
            "history": [
              {"role": "user", "content": "Hi"},
              {"role": "assistant", "content": "Hello"}
            ]
          }
        };
        return http.Response(jsonEncode(response), 200);
      });

      final mcpService = MCPService(client: mockClient);

      final response = await mcpService.sendMessage(
        sessionId: 'test-session',
        message: 'test message',
        history: [],
      );

      expect(attempts, 3);
      expect(response, isA<MCPResponse>());
      expect(response.mcpOutput.text, 'Hello');
    });

    test('sendMessage throws an exception on non-200 status code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final mcpService = MCPService(client: mockClient);

      expect(
        () => mcpService.sendMessage(
          sessionId: 'test-session',
          message: 'test message',
          history: [],
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}