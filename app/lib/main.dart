import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ChatProvider? chatProvider;
  const MyApp({super.key, this.chatProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>.value(
      value: chatProvider ?? ChatProvider(),
      child: MaterialApp(
        title: 'BrainDock',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
