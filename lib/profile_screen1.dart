// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen1 extends StatefulWidget {
  const ProfileScreen1({
    super.key,
  });

  @override
  State<ProfileScreen1> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen1> {
  ImageProvider avatar = FirebaseAuth.instance.currentUser!.photoURL == null
      ? Image.asset('assets/avatar.jpeg').image
      : Image.network(FirebaseAuth.instance.currentUser!.photoURL!).image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: ProfileScreen(
              avatar: GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image.
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);

                  setState(() {
                    if (kIsWeb) {
                      avatar = Image.network(image!.path).image;
                    } else {
                      avatar = Image.file(File(image!.path)).image;
                    }
                  });

                  final storageRef =
                      FirebaseStorage.instance.ref('profile_pics');
                  final avatarRef = storageRef
                      .child("${FirebaseAuth.instance.currentUser!.uid}.jpg");

                  try {
                    if (!kIsWeb) {
                      await avatarRef
                          .putFile(File(image!.path))
                          .then((p0) async {
                        print(await p0.ref.getDownloadURL());

                        FirebaseAuth.instance.currentUser!
                            .updatePhotoURL(await p0.ref.getDownloadURL());
                      });
                    } else {
                      await avatarRef
                          .putData(await image!.readAsBytes())
                          .then((p0) async {
                        print(await p0.ref.getDownloadURL());

                        FirebaseAuth.instance.currentUser!
                            .updatePhotoURL(await p0.ref.getDownloadURL());
                      });
                    }
                  } on FirebaseException catch (e) {
                    // ...
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: avatar)),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
