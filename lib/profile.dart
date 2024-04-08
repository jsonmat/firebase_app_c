import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  String uid;
  Map<String, dynamic> data;
  Profile({super.key, required this.uid, required this.data});

  @override
  State<Profile> createState() => _ProfileState(uid: uid, data: data);
}

class _ProfileState extends State<Profile> {
  String uid;
  Map<String, dynamic> data;
  _ProfileState({required this.uid, required this.data});

  bool isBusinessOwner = false;
  bool paid = false;
  FirebaseFirestore? db;

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isBusinessOwner = data['isBusinessOwner'];
    paid = widget.data['paid'];
    db = FirebaseFirestore.instance;
    lnameController.text = data['last_name'];
    fnameController.text = data['first_name'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.data['first_name']} ${widget.data['last_name']} - ${widget.data['isBusinessOwner'] ? "Business Owner" : "Customer"}'),
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
              Text('Business Owner'),
              Switch(
                  value: isBusinessOwner,
                  onChanged: (b) {
                    setState(() {
                      isBusinessOwner = b;
                    });
                  }),
              SizedBox(
                height: 20,
              ),
              Text('Paid'),
              Switch(
                  value: paid,
                  onChanged: (b) {
                    setState(() {
                      paid = b;
                    });
                  }),
              SizedBox(
                height: 20,
              ),
              Text('Proof of Payment'),
              widget.data['paymentProofUrl'] == null ||
                      widget.data['paymentProofUrl'] == ""
                  ? Text('No uploaded proof of payment yet.')
                  : Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/authc-bb127.appspot.com/o/proof_payments%2Fimages.png?alt=media&token=d05e5c8a-1147-440c-8bb8-2b226d08ab5a'),
              SizedBox(
                height: 40,
              ),
              OutlinedButton(
                  onPressed: () {
                    updateData(data, isBusinessOwner, paid,
                        fnameController.text, lnameController.text);
                  },
                  child: Text('Save Changes'))
            ],
          ),
        ),
      ),
    );
  }

  void updateData(
    Map<String, dynamic> data,
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
      "paid": paid,
      "paymentProofUrl": data['paymentProofUrl']
    }; 

    db!
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(details)
        .onError((e, _) => print("Error writing document: $e"))
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Record successfuly updated.')));
    });
  }
}
