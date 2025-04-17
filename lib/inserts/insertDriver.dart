import 'package:flutter/material.dart';

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اضافة سائق'),),
      body: Padding(
        padding: EdgeInsets.all(16.5),
        child:Form(
          key:_formKey,
          child: Column(
            children: [
              TextFormField(
                controller:_drivername,
                decoration: InputDecoration(
                  hintText: 'اسم المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // حواف دائرية
                  ),
                  )
              ),
              
              SizedBox(height: 20),
              TextFormField(),
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
            ],
          ),
        ),
      
      
      ),
    );
  }
}
