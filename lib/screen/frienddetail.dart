import 'package:flutter/material.dart';
import 'package:realmchat/main.dart';

class FriendDetail extends StatelessWidget {
  final String friendName;
  // Tambahkan properti lain seperti status dan no HP
  final String friendStatus =
      "Available"; // Status bisa diganti atau diambil dari data sebenarnya
  final String friendPhoneNumber =
      "123-456-7890"; // Nomor telepon bisa diganti atau diambil dari data

  const FriendDetail({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName),
        backgroundColor: customSwatch,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Background avatar
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ), // Placeholder foto profil
            ),
            const SizedBox(height: 20),
            Text(
              friendName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              friendStatus, // Status teman
              style: const TextStyle(
                fontSize: 16,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Phone: $friendPhoneNumber", // Nomor HP teman
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
