import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realmchat/service/auth_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}
class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Search Friend", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Search for a Friend by Email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey[200],
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async => _handleSearchFriend(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 40),
            const Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildFriendRequestsList()),
          ],
        ),
      ),
    );
  }

  // Handle Search Friend Logic
  Future<void> _handleSearchFriend(BuildContext context) async {
    String friendEmail = emailController.text.trim().toLowerCase();

    if (friendEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address.')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(friendEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (result.docs.isNotEmpty) {
        DocumentSnapshot userDoc = result.docs.first;

        if (userDoc.id == currentUserId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("You can't send a friend request to yourself.")),
          );
          return;
        }

        bool? isAdded = await showDialog<bool>(
          context: context,
          builder: (context) => _buildAddFriendDialog(
              context, userDoc.data() as Map<String, dynamic>),
        );

        if (isAdded == true) {
          await authService.sendFriendRequest(currentUserId, userDoc.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Friend request sent to ${userDoc['email']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with this email.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Build Friend Requests List
  Widget _buildFriendRequestsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No friend requests yet.'));
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> friendRequests = userData['friend_requests'] ?? [];

        if (friendRequests.isEmpty) {
          return const Center(child: Text('No friend requests yet.'));
        }

        return ListView.builder(
          itemCount: friendRequests.length,
          itemBuilder: (context, index) {
            String requestId = friendRequests[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(requestId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading user...'),
                  );
                }

                if (friendRequests.contains(requestId)) {
                  return const ListTile(
                    title: Text('Duplicate friend request detected.'),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const ListTile(
                    title: Text('Unknown user'),
                  );
                }

                Map<String, dynamic> requestUserData =
                    snapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text(
                      requestUserData['username'] ?? requestUserData['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await authService.acceptFriendRequest(
                            FirebaseAuth.instance.currentUser!.uid,
                            requestId,
                          );
                        },
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await authService.rejectFriendRequest(
                            FirebaseAuth.instance.currentUser!.uid,
                            requestId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAddFriendDialog(
      BuildContext context, Map<String, dynamic> userData) {
    return AlertDialog(
      title: const Text('Add Friend'),
      content:
          Text('Do you want to send a friend request to ${userData['email']}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
