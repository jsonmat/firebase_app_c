// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:auth_c/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
  });

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  FirebaseFirestore? db;
  List<Map<String, dynamic>> hotels = [];
  List<Map<String, dynamic>> users = [];
  int countSales = 0;
  int total = 0;

  void loadUsers() {
    db = FirebaseFirestore.instance;

    final docRef = db!.collection("users");

    docRef.snapshots().listen((event) {
      users = [];

      //Get number of documents
      print(event.docs.length);

      for (var docSnapshot in event.docs) {
        // print('${docSnapshot.id} => ${docSnapshot.data()['first_name']}');
        Map<String, dynamic> data = docSnapshot.data();
        data['uid'] = docSnapshot.id;

        // Timestamp timestamp = data['dateCreated'];
        // DateTime? dt = DateTime.tryParse(timestamp.toDate().toString());
        // print(dt!.month);
        // if (dt!.month == 2) {
        //   countSales++;
        // }
        // total += int.parse(data['amount']);
        users.add(data);
      }
      print(countSales);
      print(users);
      setState(() {});
    });

    // docRef.get().then((value) {
    //   for (var docSnapshot in value.docs) {
    //     // print('${docSnapshot.id} => ${docSnapshot.data()['first_name']}');
    //     Map<String, dynamic> data = docSnapshot.data();
    //     data['uid'] = docSnapshot.id;
    //     users.add(data);
    //   }
    //   print(users);
    //   setState(() {});
    // });
  }

  void addData() {
    db = FirebaseFirestore.instance;

    final details = <String, dynamic>{
      "first_name": "Jayson",
      "last_name": "Tamayo",
      "isBusinessOwner": true
    };

    db!
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(details)
        .onError((e, _) => print("Error writing document: $e"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadHotels();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: ListView.builder(
        itemBuilder: ((context, index) {
          return ListTile(
            title: Text(
                '${users[index]['first_name']} ${users[index]['last_name']}'),
            subtitle: Text(
              'Account Type: ${users[index]['isBusinessOwner'] ? 'Business Owner' : 'Customer'}',
            ),
            leading: users[index]['photoUrl'] == null ||
                    users[index]['photoUrl'] == ""
                ? Image.asset('assets/avatar.jpeg')
                : Image.network(users[index]['photoUrl']),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (c) => Profile(
                        uid: users[index]['uid'],
                        data: users[index],
                      )));
            },
            trailing: Icon(Icons.arrow_forward_ios_rounded),
          );
        }),
        itemCount: users.length,
      ),
    );

    // return Scaffold(
    //   // floatingActionButton: FloatingActionButton(
    //   //   onPressed: () {
    //   //     addData();
    //   //   },
    //   //   child: Icon(Icons.add),
    //   // ),
    //   body: GridView.builder(
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2, // number of items in each row
    //       mainAxisSpacing: 8.0, // spacing between rows
    //       crossAxisSpacing: 8.0, // spacing between columns
    //     ),
    //     padding: EdgeInsets.all(8.0), // padding around the grid
    //     itemCount: users.length, // total number of items
    //     itemBuilder: (context, index) {
    //       // return Container(
    //       //   // color: Colors.blue,
    //       //   child: Card(
    //       //     clipBehavior: Clip.antiAliasWithSaveLayer,
    //       //     child: Column(
    //       //       children: [
    //       //         Image.network(hotels[index]['photoUrl']),
    //       //         SizedBox(
    //       //           height: 10,
    //       //         ),
    //       //         Text(
    //       //           hotels[index]['name'],
    //       //           style: TextStyle(fontSize: 18.0, color: Colors.black),
    //       //         ),
    //       //       ],
    //       //     ),
    //       //   ), // color of grid items
    //       // );
    //       return GestureDetector(
    //         onTap: () {
    //           // print('sdfsdfsdf');
    //           Navigator.of(context).push(MaterialPageRoute(
    //               builder: (c) => Profile(
    //                     uid: users[index]['uid'],
    //                     data: users[index],
    //                   )));
    //         },
    //         child: Container(
    //           // color: Colors.blue,
    //           child: Card(
    //             clipBehavior: Clip.antiAliasWithSaveLayer,
    //             child: Column(
    //               children: [
    //                 // Image.network(users[index]['photoUrl']),
    //                 Text(
    //                   users[index]['first_name'],
    //                   style: TextStyle(fontSize: 18.0, color: Colors.black),
    //                 ),
    //                 SizedBox(
    //                   height: 10,
    //                 ),
    //                 Text(
    //                   users[index]['last_name'],
    //                   style: TextStyle(fontSize: 18.0, color: Colors.black),
    //                 ),
    //                 SizedBox(
    //                   height: 10,
    //                 ),
    //                 Text(
    //                   'Account Type: ${users[index]['isBusinessOwner'] ? 'Business Owner' : 'Customer'}',
    //                   style: TextStyle(fontSize: 18.0, color: Colors.black),
    //                 ),
    //               ],
    //             ),
    //           ), // color of grid items
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
