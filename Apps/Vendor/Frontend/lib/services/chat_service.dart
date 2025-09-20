import '../models/chat_message.dart';
import 'firebase_service.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();
  
  ChatService._();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Send message
  Future<bool> sendMessage(ChatMessage message) async {
    try {
      await _firebaseService.setDocument('chatMessages', message.id, message.toMap());
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Get messages for a chat
  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('chatMessages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('createdAt', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessage.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Stream messages for real-time updates
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _firebaseService.firestore
        .collection('chatMessages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessage.fromMap(data);
      }).toList();
    });
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      await _firebaseService.updateDocument('chatMessages', messageId, {
        'isRead': true,
        'readAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }

  // Mark all messages in chat as read
  Future<bool> markAllMessagesAsRead(String chatId, String currentUserId) async {
    try {
      final messages = await getMessages(chatId);
      final unreadMessages = messages.where((m) => 
        !m.isRead && m.senderId != currentUserId
      ).toList();
      
      for (final message in unreadMessages) {
        await markMessageAsRead(message.id);
      }
      
      return true;
    } catch (e) {
      print('Error marking all messages as read: $e');
      return false;
    }
  }

  // Get unread message count for vendor
  Future<int> getUnreadCount(String vendorId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('chatMessages')
          .where('chatId', isGreaterThanOrEqualTo: 'vendor_$vendorId')
          .where('chatId', isLessThan: 'vendor_${vendorId}z')
          .where('isRead', isEqualTo: false)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Get chat list for vendor
  Future<List<Map<String, dynamic>>> getChatList(String vendorId) async {
    try {
      // This is a simplified implementation
      // In a real app, you'd have a separate chats collection
      final querySnapshot = await _firebaseService.firestore
          .collection('chatMessages')
          .where('chatId', isGreaterThanOrEqualTo: 'vendor_$vendorId')
          .where('chatId', isLessThan: 'vendor_${vendorId}z')
          .orderBy('createdAt', descending: true)
          .get();
      
      final Map<String, Map<String, dynamic>> chatMap = {};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final chatId = data['chatId'] as String;
        
        if (!chatMap.containsKey(chatId)) {
          chatMap[chatId] = {
            'chatId': chatId,
            'customerName': data['senderName'],
            'lastMessage': data['message'],
            'lastMessageTime': data['createdAt'],
            'unreadCount': 0,
          };
        }
        
        if (!data['isRead'] && data['senderId'] != vendorId) {
          chatMap[chatId]!['unreadCount'] = (chatMap[chatId]!['unreadCount'] as int) + 1;
        }
      }
      
      return chatMap.values.toList();
    } catch (e) {
      print('Error getting chat list: $e');
      return [];
    }
  }

  // Create or get chat ID
  String createChatId(String vendorId, String customerId) {
    return 'vendor_${vendorId}_customer_$customerId';
  }

  // Send text message
  Future<bool> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      final chatMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now(),
      );
      
      return await sendMessage(chatMessage);
    } catch (e) {
      print('Error sending text message: $e');
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _firebaseService.deleteDocument('chatMessages', messageId);
      return true;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }
}
