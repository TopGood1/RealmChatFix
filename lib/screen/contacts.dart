import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? foundUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Friend",
          style: TextStyle(color: Colors.white),
        ),
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
            ElevatedButton(
              onPressed: () async => _handleSearchFriend(),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
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
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (foundUser != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    (foundUser!['name'] ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(), // Inisial nama dalam huruf besar
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  (foundUser!['name'] ?? 'No Name').toUpperCase(), // Nama besar
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (foundUser!['email'] ?? 'unknown@example.com')
                      .toLowerCase(), // Email kecil
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Colors.teal),
                  onPressed: () {
                    // Logika untuk tombol chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat feature coming soon!')),
                    );
                  },
                ),
              )
            else
              const Center(
                child: Text(
                  'No user found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSearchFriend() async {
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

    setState(() {
      isLoading = true;
      foundUser = null;
    });

    try {
      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (result.docs.isNotEmpty) {
        setState(() {
          foundUser = result.docs.first.data() as Map<String, dynamic>;
        });
      } else {
        setState(() {
          foundUser = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}