import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  File? _avatar; // Untuk menyimpan file avatar sementara
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // mengambil data dari email yang sedang login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loggedInEmail = prefs.getString('saved_email');

      if (loggedInEmail != null) {
        // Cari dokumen pengguna berdasarkan email
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: loggedInEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Dokumen ditemukan
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Update UI dengan data pengguna
          _nameController.text = userData['name'] ?? 'User';
          _aboutController.text = userData['about'] ?? 'Available';
          userId = userDoc.id; // Set userId
        } else {
          // Dokumen tidak ditemukan, buat dokumen baru
          DocumentReference newUserRef =
              await _firestore.collection('users').add({
            'name': 'User',
            'about': 'available',
            'email': loggedInEmail,
          });
          userId = newUserRef.id; // Set userId ke dokumen baru
          _nameController.text = 'User';
        }
      } else {
        debugPrint("Logged in email not found in SharedPreferences.");
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _saveUserData() async {
    if (userId.isEmpty) {
      debugPrint("Error: userId is empty. Cannot save user data.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save profile. User ID is missing.')),
      );
      return; // Hentikan proses jika userId kosong
    }

    try {
      await _firestore.collection('users').doc(userId).set({
        'name': _nameController.text,
        'about': _aboutController.text, // Misalnya Anda menambahkan field ini
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );
    } catch (e) {
      debugPrint("Error saving user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    await prefs.remove('saved_email');
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _showAvatarOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _avatar = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _avatar = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Avatar'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _avatar = null;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: customSwatch,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatar != null
                        ? FileImage(_avatar!)
                        : const AssetImage('assets/avatar_placeholder.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarOptions,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: customSwatch,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'About',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _aboutController,
              decoration: InputDecoration(
                hintText: 'Enter your About',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: customSwatch,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
