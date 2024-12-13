import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realmchat/screen/chat.dart';
import 'package:realmchat/screen/contacts.dart';
import 'package:realmchat/screen/privacypolicy.dart';
import 'package:realmchat/screen/termsandcondition.dart';
import '../main.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text(
                'RealmChat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
        backgroundColor: customSwatch,
        actions: <Widget>[
          !_isSearching
              ? IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Contacts'),
          ],
        ),
        leading: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              if (value == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
              } else if (value == 'Terms and Conditions') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsAndCondition()),
                );
              } else if (value == 'Privacy Policy') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Terms and Conditions',
                    child: Text('Terms and Conditions'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Privacy Policy',
                    child: Text('Privacy Policy'),
                  )
                ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChatListScreen(),
          ContactsTab(),
        ],
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  Future<String> _fetchUserName(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['name'] as String? ?? email;
    }
    return email; // Jika nama tidak ditemukan, akan menggunakan email sebagai fallback
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return const Center(child: Text("No chats yet."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'] as List;

              final otherUserEmail = participants.firstWhere(
                (user) => user != currentEmail,
                orElse: () => null, // Penanganan jika tidak ada user lain
              );

              if (otherUserEmail == null) {
                return const SizedBox(); // Lewati jika user lain tidak ditemukan
              }

              final lastMessage = chat['lastMessage'] ?? 'No message yet';
              final timestamp = chat['timestamp'] as Timestamp?;
              final formattedTime = timestamp != null
                  ? DateFormat('hh:mm a').format(timestamp.toDate())
                  : '';

              return FutureBuilder<String>(
                future: _fetchUserName(otherUserEmail),
                builder: (context, nameSnapshot) {
                  if (!nameSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Loading...'),
                      subtitle: Text(''),
                    );
                  }

                  final otherUserName = nameSnapshot.data!;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        otherUserName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(lastMessage),
                    trailing: Text(formattedTime),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(userData: {
                            'name': otherUserName,
                            'email': otherUserEmail,
                          }),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final List<Map<String, dynamic>> _friends = []; // Daftar teman
  bool _isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentEmail)
          .get();

      final Map<String, Map<String, dynamic>> contacts = {};

      for (var doc in snapshot.docs) {
        final participants = doc['participants'] as List;
        final otherUserEmail =
            participants.firstWhere((user) => user != currentEmail, orElse: () => null);

        if (otherUserEmail != null) {
          final nameSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: otherUserEmail)
              .limit(1)
              .get();

          if (nameSnapshot.docs.isNotEmpty) {
            final name = nameSnapshot.docs.first['name'] as String? ?? otherUserEmail;
            contacts[otherUserEmail] = {'name': name, 'email': otherUserEmail};
          }
        }
      }

      setState(() {
        _friends.clear();
        _friends.addAll(contacts.values);
        _friends.sort((a, b) => a['name'].compareTo(b['name'])); // Sorting
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteContact(String email) async {
    final currentEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentEmail == null) {
      debugPrint("No current user is logged in.");
      return;
    }

    try {
      // Hapus kontak dari tampilan (state _friends)
      setState(() {
        _friends.removeWhere((friend) => friend['email'] == email);
      });

      // Cari dokumen obrolan yang melibatkan kedua peserta
      final chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentEmail)
          .get();

      for (var doc in chatQuery.docs) {
        final participants = doc['participants'] as List;
        if (participants.contains(email)) {
          // Hapus dokumen obrolan terkait
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(doc.id)
              .delete();
        }
      }

      debugPrint("Contact and related chats deleted successfully.");
    } catch (e) {
      debugPrint("Error deleting contact: $e");
    }
  }

  Future<void> _confirmDeleteContact(String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this contact? This will also delete related chat data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteContact(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFriend = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactsScreen()),
          );
          if (newFriend != null && newFriend.isNotEmpty) {
            setState(() {
              if (!_friends.any((friend) => friend['email'] == newFriend['email'])) {
                _friends.add(newFriend);
                _friends.sort((a, b) => a['name'].compareTo(b['name']));
              }
            });
          }
        },
        backgroundColor: customSwatch,
        child: const Icon(CupertinoIcons.person_add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
              ? const Center(
                  child: Text("No contacts yet."),
                )
              : ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          friend['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(friend['name']),
                      subtitle: Text(friend['email']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.teal),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(userData: {
                                    'name': friend['name'],
                                    'email': friend['email'],
                                  }),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteContact(friend['email']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}