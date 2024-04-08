import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HotelCard extends StatelessWidget {
  String photoUrl;
  String name;
  String description;
  String docId;
  HotelCard(
      {super.key,
      required this.photoUrl,
      required this.name,
      required this.description,
      required this.docId});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 150,
        // decoration: BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.3),
        //       // spreadRadius: 3,
        //       blurRadius: 1,
        //       offset: Offset(7, 5), // changes position of shadow
        //     ),
        //   ],
        // ),
        margin: const EdgeInsets.symmetric(horizontal: 11.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 10,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        FirebaseFirestore db = FirebaseFirestore.instance;
                        db.collection('hotels').doc(docId).delete();
                      },
                      icon: Icon(
                        Icons.close,
                      ))),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${name}",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                        "${description}",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.apply(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
