import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realmchat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String? loggedInEmail;

      // Cek apakah ada email yang disimpan di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      loggedInEmail = prefs.getString('saved_email');

      // Jika tidak ada, ambil email dari FirebaseAuth.currentUser
      if (loggedInEmail == null) {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          loggedInEmail = currentUser.email;
        }
      }

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
          setState(() {
            _nameController.text = userData['name'] ?? 'User';
            _aboutController.text = userData['about'] ?? 'Available';
            userId = userDoc.id; // Set userId
          });
        } else {
          // Dokumen tidak ditemukan, buat dokumen baru
          DocumentReference newUserRef =
              await _firestore.collection('users').add({
            'name': 'User',
            'about': 'available',
            'email': loggedInEmail,
          });

          setState(() {
            userId = newUserRef.id; // Set userId ke dokumen baru
            _nameController.text = 'User';
          });
        }
      } else {
        debugPrint("Failed to get email of logged-in user.");
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty!')),
      );
      return;
    }

    try {
      // Simpan data pengguna ke Firestore
      await _firestore.collection('users').doc(userId).set({
        'name': _nameController.text,
        'about': _aboutController.text, // Misalnya Anda menambahkan field ini
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );

      // Setelah berhasil menyimpan, navigasi ke halaman Home
      Navigator.pushReplacementNamed(context, '/home');
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

  Future<void> _deleteAccount() async {
    try {
      // Hapus data pengguna di Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Hapus akun pengguna di Firebase Authentication
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }

      // Hapus data di SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');

      // Setelah berhasil, navigasi ke halaman login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account Deleted Successfully!')),
      );
    } catch (e) {
      debugPrint("Error deleting account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account.')),
      );
    }
  }

Future<void> _showDeleteAccountDialog() async {
  // Menampilkan dialog konfirmasi penghapusan akun
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Text(
            'Are you sure you want to delete your account and all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(); // Directly call _deleteAccount
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed:
                    _showDeleteAccountDialog, // Menggunakan dialog konfirmasi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete Account',
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
