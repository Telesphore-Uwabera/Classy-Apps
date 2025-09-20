import 'package:firestore_chat/models/chat_entity.dart';
import 'package:Classy/requests/chat.request.dart';
import 'package:Classy/services/firebase_chat.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ChatService {
  static final FirebaseChatService _firebaseService = FirebaseChatService();

  /// Initialize chat service
  static void initialize() {
    _firebaseService.initialize();
  }

  /// Send chat message
  static Future<void> sendChatMessage(String message, ChatEntity chatEntity) async {
    try {
      // Try Firebase first
      await FirebaseChatService.sendChatMessage(message, chatEntity);
      print("✅ Message sent via Firebase");
    } catch (e) {
      print("❌ Firebase chat failed, trying fallback: $e");
      
      // Fallback to original method
      try {
        final otherPeerKey = chatEntity.peers.keys.firstWhere(
          (peerKey) => chatEntity.mainUser.id != peerKey,
        );
        
        final otherPeer = chatEntity.peers[otherPeerKey];
        final apiResponse = await ChatRequest().sendNotification(
          title: "New Message from".tr() + " ${chatEntity.mainUser.name}",
          body: message,
          topic: otherPeer!.id,
          path: chatEntity.path,
          user: chatEntity.mainUser,
          otherUser: otherPeer,
        );

        print("Result ==> ${apiResponse.body}");
      } catch (fallbackError) {
        print("❌ Fallback chat also failed: $fallbackError");
      }
    }
  }

  /// Get chat messages stream
  static Stream<List<Map<String, dynamic>>> getChatMessages(String chatId, {int limit = 100}) {
    return _firebaseService.getChatMessages(chatId, limit: limit);
  }

  /// Get user chats stream
  static Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firebaseService.getUserChats(userId);
  }

  /// Create or get chat
  static Future<Map<String, dynamic>> createOrGetChat({
    required String userId1,
    required String userId2,
    String? chatType,
  }) async {
    return await _firebaseService.createOrGetChat(
      userId1: userId1,
      userId2: userId2,
      chatType: chatType,
    );
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _firebaseService.markMessagesAsRead(chatId, userId);
  }

  /// Get unread message count
  static Stream<int> getUnreadMessageCount(String chatId, String userId) {
    return _firebaseService.getUnreadMessageCount(chatId, userId);
  }

  /// Get total unread message count
  static Stream<int> getTotalUnreadMessageCount(String userId) {
    return _firebaseService.getTotalUnreadMessageCount(userId);
  }

  /// Delete chat
  static Future<void> deleteChat(String chatId) async {
    await _firebaseService.deleteChat(chatId);
  }

  /// Delete message
  static Future<void> deleteMessage(String messageId) async {
    await _firebaseService.deleteMessage(messageId);
  }

  /// Update message
  static Future<void> updateMessage(String messageId, String newMessage) async {
    await _firebaseService.updateMessage(messageId, newMessage);
  }

  /// Search messages
  static Future<List<Map<String, dynamic>>> searchMessages(String chatId, String query) async {
    return await _firebaseService.searchMessages(chatId, query);
  }

  /// Get chat participants
  static Future<List<Map<String, dynamic>>> getChatParticipants(String chatId) async {
    return await _firebaseService.getChatParticipants(chatId);
  }

  /// Dispose resources
  static void dispose() {
    _firebaseService.dispose();
  }
}
