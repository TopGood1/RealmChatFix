import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email and password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
        'friend_requests': [],
        'friends': [],
      });

      return userCredential.user;
    } catch (e) {
      throw Exception("Registration failed: $e");
    }
  }

  // Login user with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Send friend request
  Future<void> sendFriendRequest(String currentUserId, String friendEmail) async {
  try {
    QuerySnapshot userSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: friendEmail)
        .get();

    if (userSnapshot.docs.isEmpty) {
      throw Exception("User with email $friendEmail not found.");
    }

    String friendId = userSnapshot.docs.first.id;

    // Tambahkan friend request ke user target
    await _firestore.collection('users').doc(friendId).update({
      'friend_requests': FieldValue.arrayUnion([currentUserId]),
    });

    print("Friend request sent successfully to $friendEmail");
  } catch (e) {
    print("Failed to send friend request: $e");
    throw Exception("Failed to send friend request: $e");
  }
}

  // Accept friend request
  Future<void> acceptFriendRequest(String currentUserId, String friendId) async {
    try {
      // Add friend to current user
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Add current user to friend's friend list
      await _firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      // Remove friend request
      await _firestore.collection('users').doc(currentUserId).update({
        'friend_requests': FieldValue.arrayRemove([friendId]),
      });
    } catch (e) {
      throw Exception("Failed to accept friend request: $e");
    }
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String currentUserId, String friendId) async {
    try {
      // Remove friend request from the user's document
      await _firestore.collection('users').doc(currentUserId).update({
        'friend_requests': FieldValue.arrayRemove([friendId]),
      });
    } catch (e) {
      throw Exception("Failed to reject friend request: $e");
    }
  }

  // Fetch current user data
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserData() async {
    return await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
  }
}
