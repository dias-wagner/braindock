import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:braindock_client/main.dart';
import 'package:braindock_client/providers/chat_provider.dart';
import 'package:braindock_client/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class MockChatProvider extends ChatProvider {
  @override
  Future<void> sendMessage(String message) async {
    // Do nothing
  }
}

void main() {
  testWidgets('MyApp builds and displays ChatScreen', (WidgetTester tester) async {
    // Create a mock ChatProvider
    final mockChatProvider = MockChatProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(chatProvider: mockChatProvider));

    // Verify that ChatScreen is displayed
    expect(find.byType(ChatScreen), findsOneWidget);

    // Verify that the title is displayed
    expect(find.text('BrainDock Chat'), findsOneWidget);
  });
}