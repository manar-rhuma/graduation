import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class Sinup extends StatefulWidget {
  const Sinup({super.key});

  @override
  State<Sinup> createState() => _LoginState();
}

class _LoginState extends State<Sinup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              CircleAvatar(
                radius: 170, // حجم دائرة الصورة
                backgroundImage: AssetImage(
                  'images/logo.png',
                ), // استخدام backgroundImage بدل Image.asset في CircleAvatar
              ),
              SizedBox(height: 50),
              FormSinup(),
            ],
          ),
        ),
      ),
    );
  }
}

class FormSinup extends StatefulWidget {
  const FormSinup({super.key});

  @override
  State<FormSinup> createState() => _FormSinupState();
}

class _FormSinupState extends State<FormSinup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String email;

  // تسجيل الدخول باستخدام Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return; // إذا قام المستخدم بإلغاء التسجيل
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول إلى Firebase باستخدام بيانات حساب Google
      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لديك حساب بالفعل')));
    } on FirebaseAuthException catch (e) {
      print("حدث خطأ أثناء تسجيل الدخول: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'بريدك الالكتروني',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: Icon(Icons.email, color: Colors.blue),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'رجاء إدخال البريد الإلكتروني';
              }
              return null;
            },
            onChanged: (value) {
              email = value;
            },
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signInWithGoogle, // تنفيذ تسجيل الدخول باستخدام Google
            child: Text('تسجيل  '),
          ),
        ],
      ),
    );
  }
}
