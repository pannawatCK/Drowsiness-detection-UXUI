import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late Future<void> _initializeControllerFuture;
  CameraController? _controller;
  late Timer _timer;
  String _timeString = '';
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture =
        _setupCamera(); // กำหนดค่า `_initializeControllerFuture`
    _startTimer(); // เริ่มจับเวลา
  }

  Future<void> _setupCamera() async {
    if (await Permission.camera.request().isGranted) {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      await _controller?.initialize(); // รอการ initialize กล้อง
    } else {
      throw Exception("ไม่ได้รับสิทธิ์ในการใช้กล้อง");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year}';
    final String formattedTime =
        '${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')} : ${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('WARNING!'),
          content: Text('นี่คือการเตือนที่จำลองขึ้น'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดป๊อปอัป
              },
              child: Text('Touch to turn off notifications'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose(); // ปิด Controller กล้อง
    _timer.cancel(); // หยุด Timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // ลบปุ่มย้อนกลับ
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DATE: $_dateString', style: TextStyle(fontSize: 16)),
                Text('TIME: $_timeString', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // ตรวจสอบว่า `_controller` มีค่าไม่เป็น null ก่อนเรียกใช้งาน
                  if (_controller != null && _controller!.value.isInitialized) {
                    return Center(
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Transform.scale(
                            scale: 3.3, // ปรับค่าตามที่เหมาะสม
                            child: SizedBox(
                              width: 300, // ความกว้างของมุมมองกล้อง
                              height: 400, // ความสูงของมุมมองกล้อง
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),
                      ),

                     
                    );
                  } else {
                    return Center(
                      child: Text(
                        'กล้องไม่พร้อมใช้งาน',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: const Text("TURNOFF"),
                ),
                ElevatedButton(
                  onPressed: _showAlert, // แสดงป๊อปอัปเมื่อกด
                  child: Text('แสดงเตือน'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
