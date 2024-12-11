import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      //create user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //menyimpan data user jika belum ada
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email':email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Send friend request
  Future<void> sendFriendRequest(String currentUserId, String friendId) async {
    if (currentUserId == friendId) {
      throw Exception("You can't send a friend request to yourself.");
    }

    DocumentSnapshot friendDoc =
        await _firestore.collection('users').doc(friendId).get();

    if (!friendDoc.exists) {
      throw Exception("User not found.");
    }

    List<dynamic> friendRequests = friendDoc['friend_requests'] ?? [];
    List<dynamic> friends = friendDoc['friends'] ?? [];

    if (friendRequests.contains(currentUserId)) {
      throw Exception("Friend request already sent.");
    }

    if (friends.contains(currentUserId)) {
      throw Exception("This user is already your friend.");
    }

    // Add friend request
    await _firestore.collection('users').doc(friendId).update({
      'friend_requests': FieldValue.arrayUnion([currentUserId]),
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(
      String currentUserId, String friendId) async {
    try {
      // Add friend to current user
      WriteBatch batch = _firestore.batch();

      DocumentReference currentUserDoc =
          _firestore.collection('users').doc(currentUserId);
      DocumentReference friendDoc =
          _firestore.collection('users').doc(friendId);

      batch.update(currentUserDoc, {
        'friends': FieldValue.arrayUnion([friendId]),
        'friend_requests': FieldValue.arrayRemove([friendId]),
      });

      batch.update(friendDoc, {
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to accept friend request: $e");
    }
  }

  // Reject friend request
  Future<void> rejectFriendRequest(
      String currentUserId, String friendId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friend_requests': FieldValue.arrayRemove([friendId]),
      });
    } catch (e) {
      throw Exception("Failed to reject friend request: $e");
    }
  }
}
