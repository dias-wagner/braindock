// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MCPMessage _$MCPMessageFromJson(Map<String, dynamic> json) => MCPMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$MCPMessageToJson(MCPMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

MCPState _$MCPStateFromJson(Map<String, dynamic> json) => MCPState(
      history: (json['history'] as List<dynamic>)
          .map((e) => MCPMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MCPStateToJson(MCPState instance) => <String, dynamic>{
      'history': instance.history,
    };

MCPInput _$MCPInputFromJson(Map<String, dynamic> json) => MCPInput(
      text: json['text'] as String,
    );

Map<String, dynamic> _$MCPInputToJson(MCPInput instance) => <String, dynamic>{
      'text': instance.text,
    };

MCPRequest _$MCPRequestFromJson(Map<String, dynamic> json) => MCPRequest(
      sessionId: json['session_id'] as String,
      mcpInput: MCPInput.fromJson(json['mcp_input'] as Map<String, dynamic>),
      mcpState: MCPState.fromJson(json['mcp_state'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MCPRequestToJson(MCPRequest instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'mcp_input': instance.mcpInput,
      'mcp_state': instance.mcpState,
    };

MCPResponse _$MCPResponseFromJson(Map<String, dynamic> json) => MCPResponse(
      sessionId: json['session_id'] as String,
      mcpOutput: json['mcp_output'] as String,
      mcpState: MCPState.fromJson(json['mcp_state'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MCPResponseToJson(MCPResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'mcp_output': instance.mcpOutput,
      'mcp_state': instance.mcpState,
    };
