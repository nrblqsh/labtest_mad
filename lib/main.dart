import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'SQLiteDB.dart';
import 'bmi.dart';


void main() {
  runApp(MaterialApp(
    home: bmiCalcScreen(),
  ));
}

class bmiCalcScreen extends StatefulWidget {
  const bmiCalcScreen({Key? key}) : super(key: key);

  @override
  State<bmiCalcScreen> createState() => _bmiCalcScreenState();
}

class _bmiCalcScreenState extends State<bmiCalcScreen> {
  final List<BMI> bmis = [];
  String _status = '';
  List gender1 = ['Female', 'Male'];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController  bmiController= TextEditingController();
  var bmi = 0.0;
  var isMale = true;

  void _addInfo() async {
    String name = nameController.text.trim();
    String height = heightController.text.trim();
    String weight = weightController.text.trim();
    String bmiValue = bmiController.text.trim();
    String gender = isMale ? 'Male' : 'Female';
    bmiController.text = bmi.toString();
    if (name.isNotEmpty && height.isNotEmpty && weight.isNotEmpty) {
      BMI bm = BMI(name, double.parse(height), double.parse(weight), bmi);
      calculateBMI();

      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("name", nameController.text);
      await pref.setDouble("height", double.parse(heightController.text));
      await pref.setDouble("weight", double.parse(weightController.text));
      await pref.setDouble("bmi", double.parse(bmiController.text));

      await SQLiteDB().insertBMI('bmi', {
        'name': name,
        'height': double.parse(height),
        'weight': double.parse(weight),
        'gender': isMale ? 'Male' : 'Female',
        'status': _status,
      });

      setState(() {
        nameController.clear();
        heightController.clear();
        weightController.clear();


      });
    }

  }


  void calculateBMI () {
    double height = double.parse(heightController.text.trim());
    double weight = double.parse(weightController.text.trim());

    height = height / 100.0;

    bmi = weight / (height * height);

    // Update the BMI text field with the calculated BMI value
    bmiController.text = bmi.toStringAsFixed(2);

    if( isMale){
      if(bmi< 18.5)
      {
        _status = "Underweight. Careful during strong wind!";
      }
      else if(bmi>= 18.5 && bmi<=24.9){
        _status = "That’s ideal! Please maintain";
      }
      else if(bmi>= 25.0 && bmi<=29.9){
        _status = "Overwight! Work out please";
      }
      else {
        _status = "Whoa Obese! Dangerous Mate";
      }


    }
    else{
      if(bmi< 16)
      {
        _status = "Underweight. Careful during strong wind!";
      }
      else if(bmi>= 16 && bmi<=22){
        _status = "That’s ideal! Please maintain";
      }
      else if(bmi>= 22.0 && bmi<=27.0){
        _status = "Overwight! Work out please";
      }
      else {
        _status = "Whoa Obese! Dangerous Mate";
      }
    }


  }
  @override
  void initState(){
    super.initState();
    retrieveData();
  }

  Future<void> retrieveData() async {
    List<Map<String, dynamic>> previousData = await SQLiteDB().queryAll('bmi');
    if (previousData.isNotEmpty) {
      Map<String, dynamic> latestData = previousData.last; //  take the last data in the list
      setState(() {
        nameController.text = latestData['name'];
        heightController.text = latestData['height'].toString();
        weightController.text = latestData['weight'].toString();
        gender1 = latestData['gender'];
      });
    }
  }

// test
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Weight in KG'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: bmiController,
                decoration: InputDecoration(labelText: 'BMI'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: Radio(
                    value: true,
                    groupValue: isMale,
                    onChanged: (value) {
                      setState(() {
                        isMale = true;
                      });
                    },
                  ),
                ),
                Text('Male'),
                SizedBox(width: 100), // Add space between Male and Female
                Container(
                  width: 50,
                  height: 50,
                  child: Radio(
                    value: false,
                    groupValue: isMale,
                    onChanged: (value) {
                      setState(() {
                        isMale = false;
                      });
                    },
                  ),
                ),
                Text('Female'),
              ],
            ),
            ElevatedButton(
              onPressed: _addInfo,
              child: Text('Calculate BMI and Save'),


            ),

          SizedBox(height:20),
            Text(
               '$_status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}