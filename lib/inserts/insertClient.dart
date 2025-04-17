import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scanclean/screens/mapScreen.dart';
import 'package:latlong2/latlong.dart';

class Insertclient extends StatefulWidget {
  const Insertclient({super.key});

  @override
  State<Insertclient> createState() => _InsertclientState();
}

class _InsertclientState extends State<Insertclient> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //يلي بيدخلهم المستخدم input
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phoneNumberOne = TextEditingController();
  final TextEditingController _phoneNumberTwo = TextEditingController();
  LatLng? _clientLocation;
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

  Future<void> _saveClientData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      await FirebaseFirestore.instance.collection('clients').add({
        'username': _username.text,
        'phone1': _phoneNumberOne.text,
        'phone2': _phoneNumberTwo.text,
        'municipality': _selectedMunicipality,
        'email': email,
        'location':
            _clientLocation != null
                ? {
                  'lat': _clientLocation!.latitude,
                  'lng': _clientLocation!.longitude,
                }
                : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حفظ البيانات بنجاح')));

      // مسح الحقول بعد الحفظ
      _formKey.currentState!.reset();
      _username.clear();
      _phoneNumberOne.clear();
      _phoneNumberTwo.clear();
      setState(() {
        _selectedMunicipality = null;
      });
    } catch (e) {
      print('Error saving client: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحفظ')));
    }
  }

  String? _selectedMunicipality;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيانات العميل')),
      body: Padding(
        padding: EdgeInsets.all(16.5),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _username,
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
                    return 'رجاء إدخل اسم مستخدم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberOne,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف الاول',
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
                controller: _phoneNumberTwo,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف الثاني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (String? valua) {
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
              ElevatedButton.icon(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (result != null && result is LatLng) {
      print("تم اختيار الموقع: $result"); // 🔍 نطبع النتيجة هنا
      setState(() {
        _clientLocation = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار الموقع بنجاح')),
      );
    } else {
      print("لم يتم اختيار موقع");
    }
  },
  icon: Icon(Icons.map),
  label: Text('اختيار الموقع من الخريطة'),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
  ),
),


              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveClientData();
                  } else {
                    print('النموذج يحتوي على أخطاء');
                  }
                },
                child: Text('دخول'),
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
