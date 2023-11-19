import 'package:chat_app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  Future<void> sendMessage(String receiverId, String message) async {
    // get the current user
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    //get the current user

    // fetch the current user's display name
    final String currentUserName =
        _firebaseAuth.currentUser!.displayName.toString();

    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // add a new message to the database
    await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  //get messages from a chat room
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
    // Get the last message from a chat room
  Future<Message?> getLastMessage(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> lastMessageData = snapshot.docs.first.data();
      return Message.fromMap(lastMessageData);
    } else {
      return null;
    }
  }

}
