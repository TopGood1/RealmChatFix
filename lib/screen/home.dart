import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    // Inisialisasi TabController dengan dua tab
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
          ChatEmptyState(),
          ContactsTab(),
        ],
      ),
    );
  }
}

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            const IconData(0xf03b7, fontFamily: 'MaterialIcons'), // wechat_rounded
            color: customSwatch,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            "You haven't chat yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Fungsi tombol tidak diimplementasikan
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: customSwatch,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Start Chatting',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                )),
          ),
        ],
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
  final List<String> _friends = []; // Daftar teman yang ditambahkan

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
              _friends.add(newFriend);
            });
          }
        },
        backgroundColor: customSwatch,
        child: const Icon(CupertinoIcons.person_add),
      ),
      body: _friends.isEmpty
          ? const Center(
              child: Text("No friends added yet."),
            )
          : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_friends[index]),
                );
              },
            ),
    );
  }
}