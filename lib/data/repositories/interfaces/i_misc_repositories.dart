import '../../../domain/models/models.dart';

abstract class IChatRepository {
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
  });
  Future<void> markAsRead(String conversationId);
}

abstract class INotificationRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> registerFcmToken(String token);
}

abstract class IProfileRepository {
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<String> uploadAvatar(String filePath);
  Future<void> updateBabysitterProfile(Map<String, dynamic> data);
  Future<void> uploadVerificationDocument({
    required String type,
    required String filePath,
  });
}

abstract class IChildRepository {
  Future<List<dynamic>> getChildren();
  Future<dynamic> addChild(Map<String, dynamic> data);
  Future<dynamic> updateChild(String id, Map<String, dynamic> data);
  Future<void> deleteChild(String id);
}

abstract class ITrustCircleRepository {
  Future<List<dynamic>> getTrustCircle();
  Future<void> inviteMember({String? email, String? phone});
  Future<void> removeMember(String memberId);
}

