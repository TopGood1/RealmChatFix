import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realmchat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realmchat/utility/auth_service.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final AuthService authService = AuthService(); // Inisialisasi AuthService

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Friend",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: customSwatch,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  try {
                    // Ambil UID pengguna saat ini
                    String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;

                    // Cari user berdasarkan email
                    QuerySnapshot result = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: emailController.text.trim())
                        .get();

                    if (result.docs.isNotEmpty) {
                      // User ditemukan
                      Map<String, dynamic> userData =
                          result.docs.first.data() as Map<String, dynamic>;

                      // Tampilkan dialog konfirmasi
                      bool? isAdded = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildAddFriendDialog(context, userData);
                        },
                      );

                      if (isAdded == true) {
                        // Kirim friend request menggunakan AuthService
                        await authService.sendFriendRequest(
                            currentUserId, emailController.text.trim());

                        // Tampilkan notifikasi
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Friend request sent to ${userData['email']}'),
                            ),
                          );
                        }
                      }
                    } else {
                      // Jika user tidak ditemukan
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No user found with this email.'),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Tangani error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: customSwatch,
              ),
              child: const Text(
                "Search",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('friend_requests')
                  .where('to', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return const Text('No friend requests yet.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    String fromEmail = snapshot.data.docs[index]['fromEmail'];
                    return ListTile(
                      title: Text(fromEmail),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          // Terima permintaan teman
                          await _acceptFriendRequest(fromEmail);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customSwatch,
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menerima permintaan teman
  Future<void> _acceptFriendRequest(String friendEmail) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Ambil userId pengirim permintaan
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: friendEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String friendId = snapshot.docs.first.id;

      // Tambahkan teman ke koleksi friends
      await FirebaseFirestore.instance.collection('friends').doc(currentUserId).set({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Hapus permintaan teman
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('to', isEqualTo: currentUserId)
          .where('fromEmail', isEqualTo: friendEmail)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi menambahkan teman
  Widget _buildAddFriendDialog(
      BuildContext context, Map<String, dynamic> userData) {
    return AlertDialog(
      title: const Text('Add Friend'),
      content:
          Text('Do you want to send a friend request to ${userData['email']}?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // Tidak jadi menambahkan
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true); // Konfirmasi menambahkan teman
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
