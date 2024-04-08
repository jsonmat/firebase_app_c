import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  FirebaseFirestore? db;
  Set<Marker> hotels = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  void loadHotels() {
    db = FirebaseFirestore.instance;

    final docRef = db!.collection("hotels");

    docRef.get().then((value) {
      for (var docSnapshot in value.docs) {
        print('${docSnapshot.id} => ${docSnapshot.data()['name']}');
        Marker m = Marker(
          markerId: MarkerId(docSnapshot.data()['name']),
          position: LatLng(
              docSnapshot.data()['latitude'], docSnapshot.data()['longitude']),
        );
        _kLake = CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(docSnapshot.data()['latitude'],
                docSnapshot.data()['longitude']),
            tilt: 59.440717697143555,
            zoom: 19.151926040649414);
        hotels.add(m);
      }

      hotels.where(
        (element) {
          return element.markerId.value == '';
        },
      );

      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      extendBody: true,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: hotels,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                color: Colors.white,
                child: TextFormField(
                  onChanged: (value) {},
                )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToHotel,
        label: const Text('Go to Monarch!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToHotel() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
