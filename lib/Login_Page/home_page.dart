import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // สำหรับ Firestore
import 'camera_page.dart';
import 'setting_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String phoneNumber = 'Loading...'; // เก็บเบอร์โทรที่ดึงมาจาก Firestore

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMyDialog(context); // แสดง Popup เมื่อ widget ถูกสร้างเสร็จ
    });
    _fetchPhoneNumber(); // ดึงข้อมูลเบอร์โทรจาก Firestore
    requestSmsPermission();
  }

  Future<void> _fetchPhoneNumber() async {
    try {
      // ดึงข้อมูลจาก Firestore
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          phoneNumber = doc['phoneNumber'] ?? 'Not Set'; // อัปเดตเบอร์โทรใน UI
        });
      } else {
        setState(() {
          phoneNumber = 'Not Set'; // หากไม่มีข้อมูลใน Firestore
        });
      }
    } catch (e) {
      setState(() {
        phoneNumber =
            'Error fetching phone number'; // แสดงข้อความเมื่อเกิดข้อผิดพลาด
      });
    }
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[700], // สีพื้นหลัง Popup
          title: Text(
            'Validate',
            style: TextStyle(color: Colors.white), // สีข้อความหัวเรื่อง
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Divider(color: Colors.white),
                Text(
                  'Phone number Emergency contacts',
                  style: TextStyle(color: Colors.white), // สีข้อความทั่วไป
                ),
                Text(
                  phoneNumber, // แสดงเบอร์โทรที่ดึงมาจาก Firestore
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'If you want to add or change phone number go to Settings > Phone number.',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'This popup will pop up every time you enter the app. For your safety',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.check),
              label: const Text("Confirm"),
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
        title: const Text(
          "CAR CARE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 130.0,
              backgroundColor:
                  const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลัง Avatar
              child: Image.asset(
                'assets/car.png', // แสดงรูปภาพจาก assets
                fit: BoxFit.cover, // ปรับขนาดให้พอดีใน CircleAvatar
                width: 500.0, // กำหนดขนาดความกว้างและสูงของรูปภาพ
                height: 500.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวตั้ง
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black, // สีข้อความ
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
                  ),
                  Text(
                    'New Driving Experience !',
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black, // สีข้อความ
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
            SizedBox(
              width: 160, // ขนาดของปุ่มทั้งสอง
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CameraPage()));
                },
                icon: const Icon(Icons.camera),
                label: const Text("Start camera"),
              ),
            ),
            SizedBox(height: 5), // เว้นระยะระหว่างปุ่ม
            SizedBox(
              width: 160, // ขนาดของปุ่มทั้งสอง
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                icon: const Icon(Icons.settings),
                label: const Text("Settings"),
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: 160, // ขนาดของปุ่ม
              child: ElevatedButton.icon(
                onPressed: (() {
                  FirebaseAuth.instance.signOut();
                }),
                icon: const Icon(Icons.logout_sharp),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestSmsPermission() async {
    PermissionStatus status = await Permission.sms.request();

    if (status.isGranted) {
      print("SMS permission granted");
    } else if (status.isDenied) {
      print("SMS permission denied");
    } else if (status.isPermanentlyDenied) {
      print("SMS permission permanently denied. Please enable it in settings.");
      // สามารถเปิดไปที่การตั้งค่าได้
      openAppSettings();
    }
  }
}
