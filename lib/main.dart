// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:auth_c/firebase_options.dart';
import 'package:auth_c/home_screen.dart';
import 'package:auth_c/maps.dart';
import 'package:auth_c/profile_complete.dart';
import 'package:auth_c/profile_screen1.dart';
import 'package:auth_c/stat_screen.dart';
import 'package:auth_c/users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedTab = 0;
  bool uncompletedProfile = false;
  List<Widget> screens = [
    HomeScreen(),
    UsersScreen(),
    MapSample(),
    StatScreen(),
    ProfileScreen1()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      checkIfProfileCompleted();
    });
  }

  Future<void> checkIfProfileCompleted() async {
    bool exist = await checkExist(FirebaseAuth.instance.currentUser!.uid);
    print(exist);

    setState(() {
      uncompletedProfile = !exist;
    });
  }

  Future<String> checkRole() async {
    String role = "Customer";
    FirebaseFirestore db = FirebaseFirestore.instance;

    final docRef = db!.collection("hotels");

    await docRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      role = value.data()!['isBusinessOwner'];
    });
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        canvasColor: Colors.purple,
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          // ···
          brightness: Brightness.light,
        ),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // ···
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.oswald(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: Scaffold(
        body: FirebaseAuth.instance.currentUser == null
            ? SignInScreen(
                headerBuilder: (context, constraints, shrinkOffset) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        FlutterLogo(
                          size: 100,
                        ),
                        Spacer(),
                        // Text(
                        //   'Flutter',
                        //   style: TextStyle(fontSize: 20),
                        // ),
                      ],
                    ),
                  );
                },
                providers: [EmailAuthProvider()],
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) async {
                    // setState(() {});
                  }),
                  AuthStateChangeAction<UserCreated>((context, state) {
                    // setState(() {});
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (c) => CompleteProfile()));
                  })
                ],
              )
            : (uncompletedProfile ? CompleteProfile() : screens[selectedTab]),
        bottomNavigationBar:
            FirebaseAuth.instance.currentUser == null || uncompletedProfile
                ? null
                : BottomNavigationBar(
                    currentIndex: selectedTab,
                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home,
                            // color: Colors.cyan,
                          ),
                          label: 'Hotels'),
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person_2_rounded,
                            // color: Colors.cyan,
                          ),
                          label: 'Users'),
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.map,
                            // color: Colors.cyan,
                          ),
                          label: 'Map'),
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.stacked_bar_chart,
                            // color: Colors.cyan,
                          ),
                          label: 'Stats'),
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person,
                            // color: Colors.cyan,
                          ),
                          label: 'Profile'),
                    ],
                    onTap: (value) {
                      setState(() {
                        selectedTab = value;
                      });
                    },
                  ),
      ),
    );
  }

  Future<bool> checkExist(String docID) async {
    bool exist = false;
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection('users').doc(docID).get().then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      // If any error
      return false;
    }
  }
}
