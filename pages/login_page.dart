import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signup_page.dart';  // Import SignUpPage
import '../widgets/wave_clipper.dart';  // Import WaveClipper
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Import AuthService
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Initialize AuthService
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wavy header
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                color: Colors.blue[800],
                height: 200,
                child: Center(
                  child: Text(
                    'WELCOME TO TEAMNY',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Login Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Login:', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController, // Attach controller
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController, // Attach controller
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle Email/Password Login
                        User? user = await _authService.loginWithEmail(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        if (user != null) {
                          // Navigate to Home Page or wherever
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login Failed')),
                          );
                        }
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Text('OR'),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Login Button
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Handle Google login
                                User? user = await _authService.signInWithGoogle();
                                if (user != null) {
                                  // Navigate to Home Page or wherever
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Google Sign-In Failed')),
                                  );
                                }
                              },
                              icon: FaIcon(FontAwesomeIcons.google, color: Colors.white),
                              label: Text('Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Facebook Login Button
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Handle Facebook login
                                User? user = await _authService.signInWithFacebook();
                                if (user != null) {
                                  // Navigate to Home Page or wherever
                                  Navigator.pushReplacementNamed(context, '/home');
                                } else {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Facebook Sign-In Failed')),
                                  );
                                }
                              },
                              icon: FaIcon(FontAwesomeIcons.facebookF, color: Colors.white),
                              label: Text('Facebook'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigate to Sign Up Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text(
                            "Don't have an account? Sign up.",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
