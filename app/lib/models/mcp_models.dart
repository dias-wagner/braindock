import 'package:json_annotation/json_annotation.dart';

part 'mcp_models.g.dart';

@JsonSerializable()
class MCPMessage {
  @JsonKey(name: 'role')
  final String role;
  @JsonKey(name: 'content')
  final String content;

  MCPMessage({required this.role, required this.content});

  factory MCPMessage.fromJson(Map<String, dynamic> json) =>
      _$MCPMessageFromJson(json);

  Map<String, dynamic> toJson() => _$MCPMessageToJson(this);
}

@JsonSerializable()
class MCPState {
  @JsonKey(name: 'history')
  final List<MCPMessage> history;

  MCPState({required this.history});

  factory MCPState.fromJson(Map<String, dynamic> json) =>
      _$MCPStateFromJson(json);

  Map<String, dynamic> toJson() => _$MCPStateToJson(this);
}

@JsonSerializable()
class MCPInput {
  @JsonKey(name: 'text')
  final String text;

  MCPInput({required this.text});

  factory MCPInput.fromJson(Map<String, dynamic> json) =>
      _$MCPInputFromJson(json);

  Map<String, dynamic> toJson() => _$MCPInputToJson(this);
}

@JsonSerializable()
class MCPRequest {
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'mcp_input')
  final MCPInput mcpInput;
  @JsonKey(name: 'mcp_state')
  final MCPState mcpState;

  MCPRequest({
    required this.sessionId,
    required this.mcpInput,
    required this.mcpState,
  });

  factory MCPRequest.fromJson(Map<String, dynamic> json) =>
      _$MCPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MCPRequestToJson(this);
}

@JsonSerializable()
class MCPResponse {
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'mcp_output')
  final String mcpOutput;
  @JsonKey(name: 'mcp_state')
  final MCPState mcpState;

  MCPResponse({
    required this.sessionId,
    required this.mcpOutput,
    required this.mcpState,
  });

  factory MCPResponse.fromJson(Map<String, dynamic> json) =>
      _$MCPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MCPResponseToJson(this);
}
