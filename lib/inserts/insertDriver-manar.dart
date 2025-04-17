import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Insertdriver extends StatefulWidget {
  const Insertdriver({super.key});

  @override
  State<Insertdriver> createState() => _InsertdriverState();
}

class _InsertdriverState extends State<Insertdriver> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _municipalities = [
    'بلدية طرابلس المركز',
    'بلدية سوق الجمعة',
    'بلدية عين زارة',
    'بلدية حي الاندلس',
    'بلدية قصر بن غشير',
    'بلدية تاجوراء',
    'بلدية جنزور',
    'بلدية بوسليم',
    'بلدية الهضبة',
  ];
  String? _selectedMunicipality;
  final TextEditingController _drivername = TextEditingController();
  final TextEditingController _numOfPassengers = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();

  Future<void> _saveDrivertData() async {
    final name = _drivername.text.trim();
    final phone = _phoneNumber.text.trim();
    final passengers = _numOfPassengers.text.trim();
    final municipality = _selectedMunicipality;
    final password = _password.text.trim();
    final email = _email.text.trim();

    if (name.isEmpty ||
        passengers.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        municipality == null) {
      // يمكنك عرض رسالة تنبيه هنا
      print('يرجى تعبئة جميع الحقول');
      return;
    }

    try {
      // 1. إنشاء حساب في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. حفظ البيانات الإضافية في Firestore
      await FirebaseFirestore.instance
          .collection('drivers') // اسم المجموعة
          .doc(userCredential.user!.uid) // نستخدم uid كمعرف فريد
          .set({
            'name': name,
            'passengers': int.parse(passengers),
            'phone': phone,
            'email': email,
            'municipality': municipality,
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم التسجيل بنجاح  ')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      print(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
       print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اضافة سائق')),
      body: Padding(
        padding: EdgeInsets.all(16.5),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _drivername,
                decoration: InputDecoration(
                  hintText: 'اسم المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'رجاء إدخل اسم السائق';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _phoneNumber,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (valua) {
                  if (valua == null || valua.isEmpty) {
                    return 'من فضلك أدخل رقم الهاتف';
                  } else if (valua.length != 10) {
                    return 'رقم الهاتف غير صحيح';
                  } else
                    return null;
                },

                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // قبول الأرقام فقط
                  LengthLimitingTextInputFormatter(
                    10,
                  ), // تحديد عدد الأرقام بـ 10
                ],
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _numOfPassengers,
                decoration: InputDecoration(
                  hintText: 'عدد الركاب ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (valua) {
                  if (valua == null || valua.isEmpty) {
                    return 'من فضلك أدخل عدد الركاب ';
                  } else
                    return null;
                },

                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedMunicipality,
                decoration: InputDecoration(
                  labelText: 'البلدية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                items:
                    _municipalities.map((municipality) {
                      return DropdownMenuItem<String>(
                        value: municipality,
                        child: Text(municipality),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMunicipality = value;
                  });
                },
                validator:
                    (value) => value == null ? 'الرجاء اختيار البلدية' : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _password,
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'رجاء إدخال كلمة المرور';
                  }
                  return null;
                },
                textDirection: TextDirection.ltr, // الكتابة من اليمين لليسار
                textAlign: TextAlign.center,
                obscureText: true,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  //تنسيق وتصميم حقول الإدخال
                  hintText: 'بريد الإلكتروني',
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
                  contentPadding: EdgeInsets.symmetric(
                    //المسافة الداخلية بين النص والايقونة
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

                textDirection: TextDirection.ltr, // الكتابة من اليمين لليسار
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDrivertData();
                  } else {
                    print('النموذج يحتوي على أخطاء');
                  }
                },
                child: Text('تسجيل'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 170),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
