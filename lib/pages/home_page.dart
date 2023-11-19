import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/message.dart';
import '../services/chat/chat_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  //sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.grey.shade700,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  //build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Row(
          children: [
            Text(
              data['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              data['email'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            _buildLastMessage(data['uid']),
          ],
        ),
        onTap: () {
          //pass the clicked users UID to the chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserName: data["name"],
                receiverUserID: data["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildLastMessage(String receiverUserID) {
  return StreamBuilder<QuerySnapshot>(
    stream: _chatService.getMessages(_auth.currentUser!.uid, receiverUserID),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading last message...");
      }

      if (snapshot.hasError) {
        return Text("Error loading last message");
      }

      if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
        // Get the last message from the snapshot
        Map<String, dynamic> lastMessageData =
            snapshot.data!.docs.last.data() as Map<String, dynamic>;
        Message lastMessage = Message.fromMap(lastMessageData);

        // Check if the message is unread (not read)
        bool isUnread = !lastMessage.read;

        return Text(
          isUnread
              ? 'New Message: ${lastMessage.message}' // Add indication for unread messages
              : lastMessage.message,
          style: TextStyle(
            fontSize: 12,
            color: isUnread ? Colors.blue : Colors.black,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        );
      } else {
        return Text("No messages yet");
      }
    },
  );
}

}
