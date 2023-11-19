import "package:cloud_firestore/cloud_firestore.dart";

class Message {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool read; // Added property

  Message({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.read = false, // Default to false
  });

//convert to a map
  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderName": senderName,
      "receiverId": receiverId,
      "message": message,
      "timestamp": timestamp,
      "read": read,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map["senderId"],
      senderName: map["senderName"],
      receiverId: map["receiverId"],
      message: map["message"],
      timestamp: map["timestamp"],
      read: map["read"] ?? false, // Use default value if "read" is not present
    );
  }
}
