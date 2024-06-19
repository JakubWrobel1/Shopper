import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopper/pallete.dart';
import 'package:shopper/widgets/gradient_button.dart';
import 'package:shopper/widgets/login_field.dart';
import 'package:shopper/widgets/social_button.dart';
import 'package:shopper/pages/login_register_pages/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _passwordVisible = false; // Zmienna do kontrolowania widoczności hasła

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            String role = userDoc['role'];
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }
      } catch (e) {
        debugPrint(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in with Email & Password'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/images/signin_balls.png', scale: 25),
              const Text(
                'Login.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 25),
              SocialButton(
                  iconPath: 'assets/svgs/g_logo.svg',
                  label: 'Continue with Google',
                  onPressed: () {
                    loginWithGoogle(
                      auth: _auth,
                      context: context,
                      googleSignIn: _googleSignIn,
                    );
                  } // Przekaż funkcję logowania przez Google
                  ),
              const SizedBox(height: 15),
              const Text(
                'or',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    LoginField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        _email = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    LoginField(
                      hintText: 'Password',
                      obscureText: !_passwordVisible,
                      onSaved: (value) {
                        _password = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: 'Login',
                      onPressed: _login,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Don\'t have an account? Register',
                        style: TextStyle(
                          fontSize: 16,
                          color: Pallete.gradient2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
