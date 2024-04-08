import 'package:auth_c/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();

  String accountType = 'Customer';
  FirebaseFirestore? db;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete your profile'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First Name',
                textAlign: TextAlign.start,
              ),
              TextFormField(
                controller: fnameController,
                // initialValue: widget.data['first_name'],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Last Name',
                textAlign: TextAlign.start,
              ),
              TextFormField(
                controller: lnameController,
                // initialValue: widget.data['last_name'],
              ),
              SizedBox(
                height: 20,
              ),
              Text('Select Account Type:'),
              RadioListTile(
                  title: Text('Business Owner'),
                  value: 'Business Owner',
                  groupValue: accountType,
                  onChanged: (s) {
                    setState(() {
                      accountType = 'Business Owner';
                    });
                  }),
              RadioListTile(
                  title: Text('Customer'),
                  value: 'Customer',
                  groupValue: accountType,
                  onChanged: (s) {
                    setState(() {
                      accountType = 'Customer';
                    });
                  }),
              SizedBox(
                height: 40,
              ),
              OutlinedButton(
                  onPressed: () {
                    if (fnameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please enter your first name.')));
                    } else if (lnameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please enter your last name.')));
                    } else {
                      saveData(accountType == 'Business Owner' ? true : false,
                          false, fnameController.text, lnameController.text);
                    }
                  },
                  child: Text('Save Changes'))
            ],
          ),
        ),
      ),
    );
  }

  void saveData(
    bool isBusinessOwner,
    bool paid,
    String fname,
    String lname,
  ) {
    db = FirebaseFirestore.instance;

    final details = <String, dynamic>{
      "first_name": fname,
      "last_name": lname,
      "isBusinessOwner": isBusinessOwner,
      "paid": false,
      "paymentProofUrl": '',
      'dateCreated': Timestamp.fromDate(DateTime.now())
    };

    db!
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(details)
        .onError((e, _) => print("Error writing document: $e"))
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Record successfuly updated.')));

      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (c) => MainApp()));
      });
    });
  }
}
