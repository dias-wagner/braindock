import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/services/mcp_service.dart';
import '../lib/models/mcp_models.dart';
import 'package:provider/provider.dart';
import '../lib/providers/chat_provider.dart';
import '../lib/main.dart';

void main() {
  final mockClient = MockClient((request) async {
    final mockResponse = {
      'session_id': 'default-session',
      'mcp_output': 'Mocked reply',
      'mcp_state': {
        'history': [
          {'role': 'user', 'content': 'Hello'},
          {'role': 'assistant', 'content': 'Mocked reply'}
        ]
      }
    };
    return http.Response(jsonEncode(mockResponse), 200);
  });

  group('ChatProvider unit tests', () {
    test('updates state with mocked MCPService', () async {
      final provider = ChatProvider.withService(MCPService(client: mockClient));
      await provider.sendMessage('Hello');
      expect(provider.messages.length, 2);
      expect(provider.messages[0].role, 'user');
      expect(provider.messages[0].content, 'Hello');
      expect(provider.messages[1].role, 'assistant');
      expect(provider.messages[1].content, 'Mocked reply');
      expect(provider.isLoading, false);
      expect(provider.error, '');
    });
  });

  group('Widget tests', () {
    testWidgets('App launches and shows chat screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(chatProvider: ChatProvider.withService(MCPService(client: mockClient))),
      );
      expect(find.text('BrainDock Chat'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Send message updates chat', (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(chatProvider: ChatProvider.withService(MCPService(client: mockClient))),
      );
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      // Assert user message appears
      expect(find.text('Hello'), findsWidgets);
      // Assert assistant reply appears
      expect(find.text('Mocked reply'), findsWidgets);
    });
  });
}
