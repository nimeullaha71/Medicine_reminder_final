class ChatModel {
  final String? conversationId;
  final String? response;
  final String? messageType;
  final String? voiceUrl;
  final String? createdAt;

  ChatModel({
    this.conversationId,
    this.response,
    this.messageType,
    this.voiceUrl,
    this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic>? json) {
    try {
      print(' Parsing ChatModel from JSON: $json');
      

      if (json == null) {
        print(' Null JSON response received');
        return ChatModel(
          conversationId: null,
          response: 'Error: Null response received',
          messageType: 'error',
          createdAt: null,
        );
      }
      
      print(' JSON keys: ${json.keys.toList()}');
      

      final conversationId = json['conversation_id']?.toString();
      String response = json['response']?.toString() ?? 
                       json['message']?.toString() ?? 
                       json['text']?.toString() ?? '';
      final messageType = json['message_type']?.toString() ?? 'text';
      final voiceUrl = json['voice_url']?.toString();
      final createdAt = json['created_at']?.toString();
      
      // If still empty but we have data, maybe it's a specialty response
      if (response.isEmpty && (json.containsKey('data') || json.containsKey('medicines'))) {
        response = "Prescription analysis complete.";
      }
      
      print(' conversation_id: $conversationId');
      print(' response: $response');
      
      // Validate
      if (response.isEmpty) {
        print(' Empty response field in JSON');
        // If it's really empty, we'll try to use the raw JSON keys as a hint
        if (json.keys.isNotEmpty) {
           response = "Received response with keys: ${json.keys.join(', ')}";
        } else {
           response = 'Error: Empty response from server';
        }
      }
      
      return ChatModel(
        conversationId: conversationId,
        response: response,
        messageType: messageType,
        voiceUrl: voiceUrl,
        createdAt: createdAt,
      );
    } catch (e) {
      print(' Error parsing ChatModel: $e');
      print(' Error Type: ${e.runtimeType}');
      print(' Stack Trace: ${StackTrace.current}');
      
      return ChatModel(
        conversationId: null,
        response: 'Error parsing response: ${e.toString()}',
        messageType: 'error',
        voiceUrl: null,
        createdAt: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'response': response,
      'message_type': messageType,
      'voice_url': voiceUrl,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'ChatModel(conversationId: $conversationId, response: $response, messageType: $messageType, voiceUrl: $voiceUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel &&
        other.conversationId == conversationId &&
        other.response == response &&
        other.messageType == messageType &&
        other.voiceUrl == voiceUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return conversationId.hashCode ^
        response.hashCode ^
        messageType.hashCode ^
        voiceUrl.hashCode ^
        createdAt.hashCode;
  }
}
