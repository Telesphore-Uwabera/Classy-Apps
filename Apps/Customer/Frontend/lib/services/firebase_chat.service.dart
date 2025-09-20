import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_chat/models/chat_entity.dart';
import 'package:firestore_chat/models/peer_user.dart';
import 'package:Classy/services/auth.service.dart';
import 'package:Classy/services/firebase_data.service.dart';
import 'package:Classy/services/firebase_notification.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class FirebaseChatService {
  static final FirebaseChatService _instance = FirebaseChatService._internal();
  factory FirebaseChatService() => _instance;
  FirebaseChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDataService _firebaseDataService = FirebaseDataService();
  final FirebaseNotificationService _notificationService = FirebaseNotificationService();

  // Stream controllers for real-time chat
  final StreamController<List<Map<String, dynamic>>> _messagesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _chatsController = StreamController<List<Map<String, dynamic>>>.broadcast();

  // Streams for listening to chat data
  Stream<List<Map<String, dynamic>>> get messagesStream => _messagesController.stream;
  Stream<List<Map<String, dynamic>>> get chatsStream => _chatsController.stream;

  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _chatsSubscription;

  /// Initialize chat service
  void initialize() {
    _startRealTimeUpdates();
  }

  /// Start real-time updates for chat
  void _startRealTimeUpdates() {
    final currentUser = AuthServices.currentUser;
    if (currentUser?.id == null) return;

    // Listen to user's chat conversations
    _chatsSubscription?.cancel();
    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser!.id.toString())
        .orderBy('last_message_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final chats = snapshot.docs.map((doc) => doc.data()).toList();
      _chatsController.add(chats);
    });
  }

  /// Send chat message
  static Future<void> sendChatMessage(String message, ChatEntity chatEntity) async {
    try {
      final currentUser = AuthServices.currentUser;
      if (currentUser?.id == null) return;

      final otherPeerKey = chatEntity.peers.keys.firstWhere(
        (peerKey) => chatEntity.mainUser.id != peerKey,
      );
      final otherPeer = chatEntity.peers[otherPeerKey];

      if (otherPeer == null) return;

      // Create message data
      final messageData = {
        'id': '',
        'chat_id': chatEntity.path,
        'sender_id': currentUser!.id.toString(),
        'sender_name': chatEntity.mainUser.name,
        'sender_image': chatEntity.mainUser.image,
        'message': message,
        'message_type': 'text',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add message to Firestore
      final messageRef = FirebaseFirestore.instance.collection('messages').doc();
      messageData['id'] = messageRef.id;
      await messageRef.set(messageData);

      // Update chat last message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatEntity.path)
          .update({
        'last_message': message,
        'last_message_at': DateTime.now().toIso8601String(),
        'last_message_sender': chatEntity.mainUser.name,
      });

      // Send notification to other peer
      await _sendChatNotification(
        title: "New Message from".tr() + " ${chatEntity.mainUser.name}",
        body: message,
        recipientId: otherPeer.id,
        chatPath: chatEntity.path,
        sender: chatEntity.mainUser,
        recipient: otherPeer,
      );

      print("✅ Chat message sent successfully");
    } catch (e) {
      print("❌ Error sending chat message: $e");
    }
  }

  /// Send chat notification
  static Future<void> _sendChatNotification({
    required String title,
    required String body,
    required String recipientId,
    required String chatPath,
    required PeerUser sender,
    required PeerUser recipient,
  }) async {
    try {
      final notificationService = FirebaseNotificationService();
      
      await notificationService.createNotification(
        title: title,
        body: body,
        type: 'chat',
        data: {
          'is_chat': true,
          'chat_path': chatPath,
          'sender_id': sender.id,
          'sender_name': sender.name,
          'sender_image': sender.image,
        },
      );

      // Also send push notification if available
      // This would integrate with Firebase Cloud Messaging
      print("✅ Chat notification sent to $recipientId");
    } catch (e) {
      print("❌ Error sending chat notification: $e");
    }
  }

  /// Get chat messages
  Stream<List<Map<String, dynamic>>> getChatMessages(String chatId, {int limit = 100}) {
    return _firestore
        .collection('messages')
        .where('chat_id', isEqualTo: chatId)
        .orderBy('created_at')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get user chats
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('last_message_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Create or get chat
  Future<Map<String, dynamic>> createOrGetChat({
    required String userId1,
    required String userId2,
    String? chatType,
  }) async {
    try {
      // Check if chat already exists
      final existingChats = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId1)
          .get();

      for (final doc in existingChats.docs) {
        final chatData = doc.data();
        final participants = List<String>.from(chatData['participants'] ?? []);
        if (participants.contains(userId2)) {
          return {'id': doc.id, ...chatData};
        }
      }

      // Create new chat
      final chatRef = _firestore.collection('chats').doc();
      final chatData = {
        'id': chatRef.id,
        'participants': [userId1, userId2],
        'chat_type': chatType ?? 'direct',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_message': '',
        'last_message_at': DateTime.now().toIso8601String(),
        'last_message_sender': '',
      };

      await chatRef.set(chatData);
      return {'id': chatRef.id, ...chatData};
    } catch (e) {
      throw Exception('Failed to create or get chat: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      final messages = await _firestore
          .collection('messages')
          .where('chat_id', isEqualTo: chatId)
          .where('sender_id', isNotEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      for (final doc in messages.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
    } catch (e) {
      print("❌ Error marking messages as read: $e");
    }
  }

  /// Get unread message count for a chat
  Stream<int> getUnreadMessageCount(String chatId, String userId) {
    return _firestore
        .collection('messages')
        .where('chat_id', isEqualTo: chatId)
        .where('sender_id', isNotEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get total unread message count for user
  Stream<int> getTotalUnreadMessageCount(String userId) {
    return _firestore
        .collection('messages')
        .where('sender_id', isNotEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messages = await _firestore
          .collection('messages')
          .where('chat_id', isEqualTo: chatId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
    } catch (e) {
      print("❌ Error deleting chat: $e");
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      print("❌ Error deleting message: $e");
    }
  }

  /// Update message
  Future<void> updateMessage(String messageId, String newMessage) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'message': newMessage,
        'updated_at': DateTime.now().toIso8601String(),
        'is_edited': true,
      });
    } catch (e) {
      print("❌ Error updating message: $e");
    }
  }

  /// Search messages
  Future<List<Map<String, dynamic>>> searchMessages(String chatId, String query) async {
    try {
      final messages = await _firestore
          .collection('messages')
          .where('chat_id', isEqualTo: chatId)
          .get();

      return messages.docs
          .map((doc) => doc.data())
          .where((message) {
            final messageText = message['message']?.toString().toLowerCase() ?? '';
            return messageText.contains(query.toLowerCase());
          })
          .toList();
    } catch (e) {
      print("❌ Error searching messages: $e");
      return [];
    }
  }

  /// Get chat participants
  Future<List<Map<String, dynamic>>> getChatParticipants(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return [];

      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants'] ?? []);

      final participantsData = <Map<String, dynamic>>[];
      for (final participantId in participants) {
        final userDoc = await _firestore.collection('users').doc(participantId).get();
        if (userDoc.exists) {
          participantsData.add(userDoc.data()!);
        }
      }

      return participantsData;
    } catch (e) {
      print("❌ Error getting chat participants: $e");
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    _messagesController.close();
    _chatsController.close();
  }
}
