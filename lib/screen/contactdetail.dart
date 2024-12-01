import 'package:flutter/material.dart';
import 'package:realmchat/main.dart';

class ContactDetailScreen extends StatefulWidget {
  final String friendName;
  final String phoneNumber;

  const ContactDetailScreen({
    super.key,
    required this.friendName,
    required this.phoneNumber,
  });

  @override
  _ContactDetailScreenState createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  bool isMuted = false;
  final TextEditingController _nameController = TextEditingController();
  final String status = 'Available'; // Status default

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.friendName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Info', style: TextStyle(color: Colors.white)),
        backgroundColor: customSwatch,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.friendName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${widget.phoneNumber}', // Tampilkan nomor telepon
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Mute Notifications', style: TextStyle(fontSize: 16)),
              leading: Icon(Icons.notifications_off, color: customSwatch),
              trailing: Switch(
                value: isMuted,
                onChanged: (value) {
                  setState(() {
                    isMuted = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Block Contact', style: TextStyle(fontSize: 16)),
              leading: const Icon(Icons.block, color: Colors.redAccent),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Block Contact'),
                      content: const Text('Are you sure you want to block this contact?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Aksi blokir kontak
                            Navigator.of(context).pop();
                          },
                          child: const Text('Block'),
                        ),
                      ],
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
}
