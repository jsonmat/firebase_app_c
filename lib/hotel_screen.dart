import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HotelScreen extends StatefulWidget {
  String hotelName;
  String hotelDesc;
  String hotelImageUrl;

  HotelScreen(
      {super.key,
      required this.hotelName,
      required this.hotelDesc,
      required this.hotelImageUrl});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName),
      ),
      body: Column(
        children: [
          Hero(tag: 'hotel_image', child: Image.network(widget.hotelImageUrl)),
          Hero(tag: 'hotel_name', child: Text(widget.hotelName)),
          Hero(tag: 'hotel_desc', child: Text(widget.hotelDesc)),
          Text('Rooms')
        ],
      ),
    );
  }
}
