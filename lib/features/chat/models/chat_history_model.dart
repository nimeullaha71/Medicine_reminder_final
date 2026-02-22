class ChatHistoryModel {
  final int count;
  final List<Conversation> conversations;

  ChatHistoryModel({required this.count, required this.conversations});

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      count: json['count'] ?? 0,
      conversations: (json['conversations'] as List? ?? [])
          .map((i) => Conversation.fromJson(i))
          .toList(),
    );
  }
}

class Conversation {
  final int id;
  final int messageCount;
  final List<HistoryMessagePair> messages;
  final String createdAt;
  final String updatedAt;

  Conversation({
    required this.id,
    required this.messageCount,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      messageCount: json['message_count'] ?? 0,
      messages: (json['messages'] as List? ?? [])
          .map((i) => HistoryMessagePair.fromJson(i))
          .toList(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class HistoryMessagePair {
  final HistoryMessage? user;
  final HistoryMessage? ai;

  HistoryMessagePair({this.user, this.ai});

  factory HistoryMessagePair.fromJson(Map<String, dynamic> json) {
    return HistoryMessagePair(
      user: json['user'] != null ? HistoryMessage.fromJson(json['user']) : null,
      ai: json['ai'] != null ? HistoryMessage.fromJson(json['ai']) : null,
    );
  }
}

class HistoryMessage {
  final int messageId;
  final String messageType;
  final String? textContent;
  final String? voiceFileUrl;
  final String? imageFileUrl;
  final String createdAt;

  HistoryMessage({
    required this.messageId,
    required this.messageType,
    this.textContent,
    this.voiceFileUrl,
    this.imageFileUrl,
    required this.createdAt,
  });

  factory HistoryMessage.fromJson(Map<String, dynamic> json) {
    return HistoryMessage(
      messageId: json['message_id'] ?? 0,
      messageType: json['message_type'] ?? 'text',
      textContent: json['text_content'],
      voiceFileUrl: json['voice_file_url'],
      imageFileUrl: json['image_file_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
