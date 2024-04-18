import 'dart:async';

import 'package:auth_c/hotel_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  late ScreenCoordinate sc;
  bool infoWindowVisible = false;

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
            position: LatLng(docSnapshot.data()['latitude'],
                docSnapshot.data()['longitude']),
            infoWindow: InfoWindow(
              title: docSnapshot.data()['name'],
              snippet: 'Tap to view details',
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return HotelScreen(
                    hotelName: docSnapshot.data()['name'],
                    hotelDesc: docSnapshot.data()['description'],
                    hotelImageUrl: docSnapshot.data()['photoUrl'],
                  );
                })));
              },
            ),
            onTap: () {
              // Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              //   return HotelScreen(
              //     hotelName: docSnapshot.data()['name'],
              //     hotelDesc: docSnapshot.data()['description'],
              //     hotelImageUrl: docSnapshot.data()['photoUrl'],
              //   );
              // })));
              print('showing window');
              // _customInfoWindowController.addInfoWindow!(
              //   Text(docSnapshot.data()['name']),
              //   LatLng(docSnapshot.data()['latitude'],
              //       docSnapshot.data()['longitude']),
              // );
              setState(() {
                infoWindowVisible = true;
              });
            });
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

  loadLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);
    final GoogleMapController controller = await _controller.future;
    CameraPosition _currentLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_locationData.latitude!, _locationData.longitude!),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(50, 50)), 'assets/current_location.png');
    Marker m = Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(_locationData.latitude!, _locationData.longitude!),
        icon: customIcon,
        onTap: () {
          print('this is your location');
        });
    hotels.add(m);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHotels();
    loadLocation();
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
              _customInfoWindowController.googleMapController = controller;
              _controller.complete(controller);
            },
            markers: hotels,
            onTap: (position) async {
              _customInfoWindowController.hideInfoWindow!();
              sc = await _customInfoWindowController.googleMapController!
                  .getScreenCoordinate(position);
                  
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
          ),
          if (infoWindowVisible)
            Positioned(
                child: Container(
              width: 100,
              height: 200,
            )),
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

class MapMarker extends StatefulWidget {
  final String name;

  MapMarker({required this.name});

  @override
  _MapMarkerState createState() => _MapMarkerState();
}

class _MapMarkerState extends State<MapMarker> {
  final key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final dynamic tooltip = key.currentState;
        tooltip.ensureTooltipVisible();
      },
      child: Tooltip(
        key: key,
        message: widget.name,
        padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          color: Colors.green,
        ),
      ),
    );
  }
}
