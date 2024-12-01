import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  //Fungsi untuk logout dari aplikasi realmchat
  Future<void> _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('remember_me', false);
  await prefs.remove('saved_email');

  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            backgroundColor: customSwatch,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
        backgroundColor: customSwatch,
      ),
      body: SingleChildScrollView(
        // Menggunakan SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {},
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
              initialValue: 'User',
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
              initialValue: 'Available',
              decoration: InputDecoration(
                hintText: 'Enter your Status',
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
              'Phone Number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: '0812-5049-2326',
              decoration: InputDecoration(
                hintText: 'Default Phone Number',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            //Tombol Logout
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
                      )),
                  child: const Text('Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ))),
            )
          ],
        ),
      ),
    );
  }
}
