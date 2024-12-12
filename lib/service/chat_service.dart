import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:realmchat/model/message.dart';

class ChatService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //send message
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    //construct chat room id from user id and receiver id
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //sort the ids (memastikan agar ruangan chat selalu sama dengan user lain)
    String chatRoomId = ids.join(
        "_"); //combine the ids into a single string to use as a chatroom id

    // add new message to firebase
    await _firestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chat room id from user ids
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
