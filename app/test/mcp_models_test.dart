import 'package:flutter_test/flutter_test.dart';
import 'package:braindock_client/models/mcp_models.dart';

void main() {
  test('MCPResponse can be instantiated', () {
    final response = MCPResponse(
      sessionId: 'test-session',
      mcpOutput: MCPOutput(text: 'Hello'),
      mcpState: MCPState(history: []),
    );
    expect(response, isA<MCPResponse>());
  });
}
