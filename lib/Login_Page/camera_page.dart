import 'dart:async';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image/image.dart' as img; // ใช้ package image สำหรับการบีบอัดภาพ
import 'package:audioplayers/audioplayers.dart'; // เพิ่ม import
import 'package:flutter_sms/flutter_sms.dart';

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
  late IO.Socket _socket; // WebSocket สำหรับเชื่อมต่อเซิร์ฟเวอร์
  String _serverResponse = ''; // ข้อความจากเซิร์ฟเวอร์
  bool isStreaming = true; // ตัวแปรสถานะการส่งข้อมูล

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _setupCamera();
    _connectToServer(); // เริ่มเชื่อมต่อเซิร์ฟเวอร์
    _startTimer(); // เริ่มจับเวลา
  }

  Future<void> _setupCamera() async {
    if (await Permission.camera.request().isGranted) {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      await _controller?.initialize();

      // เริ่มส่งภาพแบบเรียลไทม์
      _controller?.startImageStream((CameraImage image) {
        _sendFrameToServer(image); // ส่งภาพไปยังเซิร์ฟเวอร์
      });
    } else {
      throw Exception("ไม่ได้รับสิทธิ์ในการใช้กล้อง");
    }
  }

  void _connectToServer() {
    // ตั้งค่า WebSocket เพื่อเชื่อมต่อ Python Server
    _socket = IO.io('http://192.168.1.39:5000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    _socket.onConnect((_) {
      print('เชื่อมต่อกับเซิร์ฟเวอร์สำเร็จ');
    });

    // ฟังข้อความจากเซิร์ฟเวอร์
    _socket.on('result', (data) {
      setState(() {
        _serverResponse = data.toString(); // เก็บข้อความที่ได้รับ
      });
      // ตรวจสอบค่า score
      if (data['score'] == 1) {
        _showSleepyWarning(); // แสดง Popup แจ้งเตือน
      }
      else if (data['score'] == 2) {
        _showSleepyWarning(); // แสดง Popup แจ้งเตือน
      }
      else if (data['score'] == 15) {
        _sendSMS("คุณกำลังง่วง โปรดหยุดพักก่อนเดินทางต่อ!", ['phone_number']); // ส่ง SMS แจ้งเตือน
      }

    });
    _socket.onDisconnect((_) => print('เซิร์ฟเวอร์ตัดการเชื่อมต่อ'));
  }

  // ฟังก์ชันสำหรับแสดง Popup และเล่นเสียง
  void _showSleepyWarning() {
    // หยุดส่งภาพไปยังเซิร์ฟเวอร์
    // _controller?.stopImageStream();

    // เล่นเสียงแจ้งเตือน
    final player = AudioPlayer();
    player.play(AssetSource('alarm.wav')); // เตรียมไฟล์เสียงในโฟลเดอร์ assets/sounds/

    // แสดง Popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('คุณกำลังง่วง!'),
          content: Text('กรุณาหยุดพักเพื่อความปลอดภัยของคุณ'),
          actions: [
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Popup
                player.stop(); // หยุดเสียง
                setState(() {
                  isStreaming = true; // กลับมาเริ่มส่งข้อมูลอีกครั้ง
                });
              },
            ),
          ],
        );
      },
    );
  }

  Uint8List? _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      // ดึง Planes จาก YUV420
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final int yRowStride = yPlane.bytesPerRow;
      final int uvRowStride = uPlane.bytesPerRow;
      final int uvPixelStride = uPlane.bytesPerPixel!;

      // สร้าง buffer สำหรับเก็บข้อมูล RGB
      final img.Image rgbImage = img.Image(width, height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yRowStride + x;

          // คำนวณตำแหน่งของ U และ V
          final int uvIndex =
              (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

          final int yValue = yPlane.bytes[yIndex];
          final int uValue = uPlane.bytes[uvIndex];
          final int vValue = vPlane.bytes[uvIndex];

          // แปลง YUV เป็น RGB
          final r = (yValue + 1.370705 * (vValue - 128)).clamp(0, 255).toInt();
          final g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
              .clamp(0, 255)
              .toInt();
          final b = (yValue + 1.732446 * (uValue - 128)).clamp(0, 255).toInt();

          // เซ็ตค่า RGB ในภาพ
          rgbImage.setPixel(x, y, img.getColor(r, g, b));
        }
      }

      // เข้ารหัสเป็น JPEG
      final List<int> jpeg = img.encodeJpg(rgbImage);

      return Uint8List.fromList(jpeg);
    } catch (e) {
      print("Conversion error: $e");
      return null;
    }
  }

  void _sendFrameToServer(CameraImage image) async {
    if (!isStreaming) return; // หยุดส่งข้อมูลหากสถานะเป็น false
    try {
      // แปลง CameraImage (YUV420) เป็น RGB หรือ JPEG
      final bytes = _convertYUV420ToImage(image);

      if (bytes != null) {
        // เข้ารหัส Base64
        final base64Image = base64Encode(bytes);

        // ส่งข้อมูลผ่าน Socket.IO
        _socket.emit('send_image', {'image': base64Image});
        print("Image sent to server");
      } else {
        print("Failed to convert image");
      }
    } catch (e) {
      print("Error: $e");
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

  @override
  void dispose() {
    _controller?.dispose();
    _timer.cancel();
    _socket.dispose(); // ปิด WebSocket
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
                  if (_controller != null && _controller!.value.isInitialized) {
                    return Center(
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Transform.scale(
                            scale: 1, // ปรับค่าตามที่เหมาะสม
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
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("TURNOFF"),
                ),
                SizedBox(height: 8),
                Text(
                  'Server Response: $_serverResponse',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}
