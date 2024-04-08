// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:auth_c/profile.dart';
import 'package:auth_c/widgets/hotel_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore? db;
  List<Map<String, dynamic>> hotels = [];
  List<Map<String, dynamic>> users = [];
  int countSales = 0;
  int total = 0;

  void loadHotels() {
    print('loadHotels');
    db = FirebaseFirestore.instance;

    final docRef = db!.collection("hotels");

    docRef.snapshots().listen((value) {
      hotels = [];
      for (var docSnapshot in value.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()['name']}');
        Map<String, dynamic> hotel = docSnapshot.data();
        hotel['docId'] = docSnapshot.id;

        hotels.add(hotel);
      }
      print(hotels);
      setState(() {});
    });
  }

  void loadHotels2(String value) {
    print('loadHotels2');
    db = FirebaseFirestore.instance;

    final docRef = db!.collection("hotels");

    docRef.get().then(
      (querySnapshot) {
        hotels = [];
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()['name']}');
          Map<String, dynamic> hotel = docSnapshot.data();
          hotel['docId'] = docSnapshot.id;
          if (docSnapshot.data()['name'].toLowerCase().contains(value) ||
              docSnapshot.data()['description'].toLowerCase().contains(value)) {
            hotels.add(hotel);
          }
        }
        print(hotels);
        setState(() {});
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHotels();
    // loadUsers();
  }

  void addData() {
    db = FirebaseFirestore.instance;

    final details = <String, dynamic>{
      "description": "Newest hotel in Pangasinan",
      "latitude": 15.921976,
      "longitude": 120.400684,
      "name": "Golden Lion Hotel",
      "photoUrl":
          "https://firebasestorage.googleapis.com/v0/b/authc-bb127.appspot.com/o/hotel_pics%2Fimages.jpeg?alt=media&token=e0b6a6c8-7fec-45a4-b9d9-541dd1deeae4",
      "rating": 5
    };

    db!.collection("hotels").add(details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // addData();
            },
            child: Icon(Icons.add),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              addData();
            },
            label: Text('Add dummy data'),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Hotels'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              onChanged: (value) {
                print(value);
                loadHotels2(value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              clipBehavior: Clip.none,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // number of items in each row
                mainAxisSpacing: 8.0, // spacing between rows
                crossAxisSpacing: 8.0, // spacing between columns
              ),
              padding: EdgeInsets.all(8.0), // padding around the grid
              itemCount: hotels.length, // total number of items
              itemBuilder: (context, index) {
                return HotelCard(
                  photoUrl: hotels[index]['photoUrl'],
                  name: hotels[index]['name'],
                  description: hotels[index]['description'],
                  docId: hotels[index]['docId'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
