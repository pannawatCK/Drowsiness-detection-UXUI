import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // สำหรับใช้กับ FilteringTextInputFormatter
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับ Firestore
import 'package:firebase_auth/firebase_auth.dart'; // สำหรับ Firebase Authentication

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final phoneController = TextEditingController(); // เก็บค่าเบอร์โทร
  String? selectedSound; // เก็บค่าเสียงที่เลือก
  bool isLoading = true; // ใช้สำหรับแสดงสถานะกำลังโหลดข้อมูล

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // ฟังก์ชันดึงข้อมูลจาก Firestore
  Future<void> loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in. Please log in first.')),
        );
        return;
      }

      final uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('settings').doc(uid).get();

      if (doc.exists) {
        setState(() {
          phoneController.text = doc.data()?['phoneNumber'] ?? ''; // เบอร์โทร
          selectedSound = doc.data()?['selectedSound'] ?? 'Hippo'; // เสียงที่เลือก
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load settings: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // เลิกแสดงสถานะโหลด
      });
    }
  }

  Future<void> saveData() async {
    final phoneNumber = phoneController.text;

    // ตรวจสอบเบอร์โทรว่าไม่ว่างเปล่า
    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in. Please log in first.')),
        );
        return;
      }

      final uid = user.uid;

      // บันทึกข้อมูลลง Firestore
      await FirebaseFirestore.instance.collection('settings').doc(uid).set({
        'phoneNumber': phoneNumber,
        'selectedSound': selectedSound ?? 'Hippo',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadData(); // ดึงข้อมูลจาก Firestore เมื่อเปิดหน้า
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // แสดง Loading ระหว่างดึงข้อมูล
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนกรอกหมายเลขโทรศัพท์
                  Text('Phone number Emergency contacts'),
                  TextField(
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                    ),
                    controller: phoneController,
                  ),
                  SizedBox(height: 20),

                  // ส่วนเลือกเสียง
                  Text('Sound'),
                  Column(
                    children: [
                      RadioListTile(
                        title: Text('Hippo (default)'),
                        value: 'Hippo',
                        groupValue: selectedSound,
                        onChanged: (value) {
                          setState(() {
                            selectedSound = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Elephant'),
                        value: 'Elephant',
                        groupValue: selectedSound,
                        onChanged: (value) {
                          setState(() {
                            selectedSound = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Chicken'),
                        value: 'Chicken',
                        groupValue: selectedSound,
                        onChanged: (value) {
                          setState(() {
                            selectedSound = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Cat'),
                        value: 'Cat',
                        groupValue: selectedSound,
                        onChanged: (value) {
                          setState(() {
                            selectedSound = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Duck'),
                        value: 'Duck',
                        groupValue: selectedSound,
                        onChanged: (value) {
                          setState(() {
                            selectedSound = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // ปุ่มบันทึก
                  ElevatedButton(
                    onPressed: saveData,
                    child: Text('SAVE'),
                  ),
                ],
              ),
            ),
    );
  }
}
