import 'package:flutter/material.dart';
import 'package:flutter_application_test/Login_Page/login_page.dart';

import 'sign_up_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool login = true;
  @override
  Widget build(BuildContext context) => login
      ? LoginPage(callToSignup : toggle)
      : RegisterPage(callToSignIn: toggle);
      void toggle() {
        setState(() {
          login = !login;
        });
      }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_application_test/register.dart';
// import 'home_page.dart'; // Replace with your actual home page


// class AuthPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasData) {
//           return HomePage(); // User is logged in, navigate to HomePage
//         }
//         return LoginPage(); // User is not logged in, show LoginPage
//       },
//     );
//   }

//   static Future<String?> registerUserFromAuth({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       return userCredential.user?.uid;
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Firebase Auth Error: ${e.message}');
//     }
//   }
// }

// class LoginPage extends StatelessWidget {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   Future<void> _loginUser(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Login Successful!')));
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _loginUser(context),
//               child: Text('Login'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).push(
//                 MaterialPageRoute(builder: (_) => RegisterPage()),
//               ),
//               child: Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

