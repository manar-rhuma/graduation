import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; 

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                backgroundImage: AssetImage('images/logo.png'), // استخدام backgroundImage بدل Image.asset في CircleAvatar
              ),
              SizedBox(height: 50),
              FormLogin(), // إضافة الفورم مباشرة هنا
            ],
          ),
        ),
      ),
    );
  }
}

class FormLogin extends StatefulWidget {
  const FormLogin({super.key});

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance; // كائن FirebaseAuth
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'بريدك الإلكتروني',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), // حواف دائرية
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: Icon(
                Icons.email,
                color: Colors.blue, // تحديد لون الأيقونة
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'رجاء إدخال البريد الإلكتروني';
              }
              return null;
            },
            onChanged: (value) {
              email = value; // تخزين البريد الإلكتروني المدخل
            },
            textDirection: TextDirection.ltr, // الكتابة من اليمين لليسار
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'كلمة المرور',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: Icon(
                Icons.key,
                color: Colors.blue, // تحديد لون الأيقونة
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'رجاء إدخال كلمة المرور';
              }
              return null;
            },
            onChanged: (value) {
              password = value; // تخزين كلمة المرور المدخلة
            },
            textDirection: TextDirection.ltr, // الكتابة من اليمين لليسار
            textAlign: TextAlign.center,
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              // تحقق من صحة المدخلات قبل محاولة تسجيل الدخول
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  // محاولة تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
                  final user = await _auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (user != null) {
                    // إذا تم تسجيل الدخول بنجاح
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
                    );
                  }
                } catch (e) {
                  // إذا حدث خطأ أثناء عملية تسجيل الدخول
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل في تسجيل الدخول: البريد الإلكتروني أو كلمة المرور غير صحيحة')),
                  );
                }
              }
            },
            child: Text('دخول'),
            ),
        ],
      ),
    );
  }
}
