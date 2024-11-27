// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DashboardPage extends StatefulWidget {
//   @override
//   _DashboardPageState createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int totalUsers = 0;
//   int todaySignIn = 0;
//   int monthSignIn = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDashboardData();
//   }

//   Future<void> _fetchDashboardData() async {
//     try {
//       // ดึงวันที่วันนี้และเดือนนี้
//       final now = DateTime.now();
//       final startOfToday = DateTime(now.year, now.month, now.day);
//       final startOfMonth = DateTime(now.year, now.month, 1);

//       // Firestore ที่เก็บข้อมูลของผู้ใช้
//       final usersCollection = FirebaseFirestore.instance.collection('users');

//       // Query: จำนวนผู้ใช้ทั้งหมด
//       final totalUsersSnapshot = await usersCollection.get();
//       final allUsers = totalUsersSnapshot.docs;
//       print("Total Users: ${allUsers.length}");

//       // Query: ผู้ที่ Sign-in วันนี้
//       final todayUsersSnapshot = await usersCollection
//           .where('lastSignIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
//           .get();
//       print("Sign-in Today: ${todayUsersSnapshot.docs.length}");

//       // Query: ผู้ที่ Sign-in ในเดือนนี้
//       final monthUsersSnapshot = await usersCollection
//           .where('lastSignIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
//           .get();
//       print("Sign-in This Month: ${monthUsersSnapshot.docs.length}");

//       // อัปเดต state
//       setState(() {
//         totalUsers = allUsers.length;
//         todaySignIn = todayUsersSnapshot.docs.length;
//         monthSignIn = monthUsersSnapshot.docs.length;
//       });
//     } catch (error) {
//       print('Error fetching dashboard data: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dashboard'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Widget แสดงข้อมูล Dashboard
//             _buildStatCard('Total Users', totalUsers, Colors.blue),
//             _buildStatCard('Sign-in Today', todaySignIn, Colors.green),
//             _buildStatCard('Sign-in This Month', monthSignIn, Colors.orange),
//           ],
//         ),
//       ),
//     );
//   }

//   // Card Widget สำหรับแสดงตัวเลข
//   Widget _buildStatCard(String title, int count, Color color) {
//     return Card(
//       color: color,
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               '$count',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                NotificationButton(label: ">3 S"),
                NotificationButton(label: ">5 S"),
                NotificationButton(label: "SMS"),
              ],
            ),
            SizedBox(height: 20),

            // Table displaying user activities
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  TableCell(child: Text('User ID', textAlign: TextAlign.center)),
                  TableCell(child: Text('Notification', textAlign: TextAlign.center)),
                  TableCell(child: Text('Date', textAlign: TextAlign.center)),
                  TableCell(child: Text('Time', textAlign: TextAlign.center)),
                ]),
                TableRow(children: [
                  TableCell(child: Text('1')),
                  TableCell(child: Text('Close eye <3 S')),
                  TableCell(child: Text('21/11/2024')),
                  TableCell(child: Text('13:00')),
                ]),
                TableRow(children: [
                  TableCell(child: Text('1')),
                  TableCell(child: Text('Close eye <3 S')),
                  TableCell(child: Text('21/11/2024')),
                  TableCell(child: Text('13:00')),
                ]),
                TableRow(children: [
                  TableCell(child: Text('2')),
                  TableCell(child: Text('Close eye <3 S')),
                  TableCell(child: Text('21/11/2024')),
                  TableCell(child: Text('13:00')),
                ]),
                TableRow(children: [
                  TableCell(child: Text('1')),
                  TableCell(child: Text('Close eye <3 S')),
                  TableCell(child: Text('21/11/2024')),
                  TableCell(child: Text('13:00')),
                ]),
              ],
            ),
            SizedBox(height: 20),

            // Total number of users section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Total number of users\n2,030',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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

class NotificationButton extends StatelessWidget {
  final String label;

  NotificationButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: Size(80, 40),
        ),
      ),
    );
  }
}
