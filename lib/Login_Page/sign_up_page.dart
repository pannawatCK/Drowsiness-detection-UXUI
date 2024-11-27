// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignUpPage extends StatefulWidget {
//   final VoidCallback callToSignIn;
//   const SignUpPage({super.key, required this.callToSignIn});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final password2Controller = TextEditingController();

//   Future<void> signUp() async {
//     if (passwordController.text == password2Controller.text) {
//       try {
//         // สร้างบัญชีผู้ใช้ใหม่ใน Firebase Authentication
//         UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text.trim(),
//           password: passwordController.text.trim(),
//         );

//         // บันทึก role ลงใน Firestore
//         await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
//           'role': 'user', // ค่า role เริ่มต้นเป็น 'user'
//           'email': emailController.text.trim(), // เก็บอีเมลผู้ใช้
//         });

//         // แสดงข้อความว่าการสมัครเสร็จสิ้น
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Sign up successful! Role assigned.")),
//         );

//         // กลับไปหน้า Login
//         widget.callToSignIn();
//       } catch (e) {
//         // แสดงข้อความแจ้งข้อผิดพลาด
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     } else {
//       // รหัสผ่านไม่ตรงกัน
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Passwords do not match.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Sign Up"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "Sign Up Page",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               decoration: const InputDecoration(labelText: "Email"),
//               controller: emailController,
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               decoration: const InputDecoration(labelText: "Password"),
//               controller: passwordController,
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               decoration: const InputDecoration(labelText: "Confirm Password"),
//               controller: password2Controller,
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: signUp,
//               icon: const Icon(Icons.arrow_forward),
//               label: const Text("Sign Up"),
//             ),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: widget.callToSignIn,
//               child: const Text(
//                 "Already have an account? Login",
//                 style: TextStyle(color: Colors.blue),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final dynamic callToSignIn;

  const RegisterPage({super.key, required this.callToSignIn});
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // บันทึกข้อมูลไปยัง Firestore
        await FirebaseFirestore.instance.collection('register').add({
          
          'email': _emailController.text,
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );

        // เคลียร์แบบฟอร์ม
        
        _emailController.clear();
        _passwordController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
