import 'package:flutter/material.dart';
import 'package:realmchat/main.dart';
import 'contactdetail.dart';
import 'package:flutter/cupertino.dart';

class ChatScreen extends StatelessWidget {
  final String friendName;

  const ChatScreen({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customSwatch,
        title: Row(
          children: [
            const Icon(CupertinoIcons.person_alt_circle, color: Colors.white,),
            const SizedBox(width: 10),
            Text(
              friendName,
              style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position:
                    const RelativeRect.fromLTRB(100, 80, 0, 0), // Atur posisi
                items: [
                  const PopupMenuItem(
                    value: 'view_contact',
                    child: Text('View Contact'),
                  ),
                ],
              ).then((value) {
                if (value == 'view_contact') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactDetailScreen(
                        friendName: friendName, phoneNumber: '0812-5049-2326',
                        // bisa tambahkan parameter lain seperti nomor kontak di sini
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //Bagian dari Chat
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BubbleMessage(
                    message: "Hi! How are you?",
                    isSentByMe: false,
                    time: "10.40 AM",
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: BubbleMessage(
                    message: "I'm good! How about you?",
                    isSentByMe: true,
                    time: "10:42 AM",
                  ),
                ),
              ],
            ),
          ),

          //Menampilkan Box Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        )),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: customSwatch,
                  ),
                  onPressed: () {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BubbleMessage extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  const BubbleMessage({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSentByMe ? customSwatch : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: isSentByMe
                  ? const Radius.circular(10)
                  : const Radius.circular(0),
              bottomRight: isSentByMe
                  ? const Radius.circular(0)
                  : const Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isSentByMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}