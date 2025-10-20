
import 'package:braindock_client/providers/chat_provider.dart';
import 'package:braindock_client/services/mcp_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ChatProvider', () {
    test('sendMessage sets error on exception and stops loading', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Test Exception');
      });

      final mcpService = MCPService(client: mockClient);
      final chatProvider = ChatProvider(mcpService: mcpService);

      await chatProvider.sendMessage('test message');

      expect(chatProvider.error, contains('Test Exception'));
      expect(chatProvider.isLoading, isFalse);
    });

    test('clearError clears the error message', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Test Exception');
      });

      final mcpService = MCPService(client: mockClient);
      final chatProvider = ChatProvider(mcpService: mcpService);

      await chatProvider.sendMessage('test message');
      chatProvider.clearError();
      expect(chatProvider.error, isEmpty);
    });
  });
}
