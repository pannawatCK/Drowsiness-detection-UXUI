import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback callToSignup;
  const LoginPage({super.key, required this.callToSignup});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login Page",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Email"),
              controller: emailController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Password"),
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text);
              },
              icon: const Icon(Icons.lock_open),
              label: const Text("Login"),
            ),
            GestureDetector(
              child: Text("Sign Up"),
              onTap: (){
                widget.callToSignup();
              },
            )
          ],
        ),
      ),
    );
  }
}
