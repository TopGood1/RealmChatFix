import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ChatScreen({super.key, required this.userData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                widget.userData['name'].substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.userData['name'],
                style: const TextStyle(
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis, // Hindari overflow
                ),
                maxLines: 1, // Batasi hanya satu baris
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_getChatId(widget.userData['email']))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender'] ==
                        FirebaseAuth.instance.currentUser?.email;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final formattedTime = timestamp != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(timestamp.toDate())
                        : 'Unknown time';

                    return Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.teal : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            formattedTime,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    _isSending ? Icons.hourglass_empty : Icons.send,
                    color: Colors.teal,
                  ),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final currentEmail = FirebaseAuth.instance.currentUser?.email;

    if (text.isEmpty || currentEmail == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final chatId = _getChatId(widget.userData['email']);
      final timestamp = FieldValue.serverTimestamp();

      // Tambahkan pesan baru ke koleksi pesan
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': text,
        'sender': currentEmail,
        'timestamp': timestamp,
      });

      // Perbarui metadata chat
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': [currentEmail, widget.userData['email']],
        'lastMessage': text,
        'timestamp': timestamp,
      }, SetOptions(merge: true));

      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  String _getChatId(String friendEmail) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) {
      throw Exception('User is not logged in');
    }
    return currentEmail.hashCode <= friendEmail.hashCode
        ? '$currentEmail-$friendEmail'
        : '$friendEmail-$currentEmail';
  }
}
