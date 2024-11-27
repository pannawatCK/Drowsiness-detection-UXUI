import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Admin Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.admin_panel_settings, size: 100, color: Colors.blue),
            const SizedBox(height: 40),
            // ปุ่ม Logout
            ElevatedButton.icon(
              onPressed: (()  {
                 FirebaseAuth.instance.signOut();
                // หลังจาก Logout ไปที่หน้า AuthPage
                
                
              }),
              icon: const Icon(Icons.logout_sharp),
              label: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
