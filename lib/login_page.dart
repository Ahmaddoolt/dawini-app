import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawintesto/models/static_values.dart';
import 'package:dawintesto/signup_users.dart';
import 'package:dawintesto/user/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';

import 'animation/splash.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoading = false;
  String? currentType;
  @override
  void initState() {
    super.initState();
    _checkStoredCredentials();
  }

  Future<void> _checkStoredCredentials() async {
    setState(() => isLoading = true);
    try {
      // Read stored credentials
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      String? type = await _secureStorage.read(key: 'type');

      // Initialize `type` to a default value if null
      if (type == null) {
        type = 'patients'; // Default to 'patients' or your preferred value
        await _secureStorage.write(key: 'type', value: type);
      }

      setState(() {
        currentType = type ?? 'patients'; // Default to 'patients' if null
      });
      // print('Stored type: $type');

      if (email == null || password == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Please log in to continue.'.tr())),
        );
        return;
      }

      // Determine the collection based on the type
      final collectionName = type == 'patients'
          ? 'patients'
          : type == 'doctors'
              ? 'doctors'
              : null;

      if (collectionName == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid user type stored. Please log in again.')),
        );
        return;
      }

      // Query the Firestore collection
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid credentials. Please log in again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show error message if email or password is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content:  Text('Email and password are required!'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Search for the user in the 'patient' collection
      final type = await _secureStorage.read(key: 'type');
      QuerySnapshot snapshot = await _firestore
          .collection(type ?? "patients")
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isEmpty) {
        // If no matching email and password
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content:  Text('No user found with this email and password!'.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // If user is found, navigate to another page
        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen()), // Replace with your target page
        );
      }
    } catch (e) {
      // Handle any errors during Firestore query
      // print("Error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: accentColor2, // Change it to your accentColor2
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                SizedBox(
                  height: size.height,
                  child: Image.network(
                    'https://thumbs.dreamstime.com/b/portrait-attractive-stylish-doc-stubble-white-lab-coat-tie-stethoscope-his-neck-having-his-arms-portrait-272359796.jpg',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaY: 12, sigmaX: 12),
                            child: SizedBox(
                              width: size.width * .9,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: size.width * .15,
                                      bottom: size.width * .1,
                                    ),
                                    child: Text(
                                      'SIGN IN'.tr(),
                                      style: TextStyle(
                                        fontSize: 37,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(
                                            0.9), // Change to accentColor2
                                      ),
                                    ),
                                  ),
                                  component(
                                    Icons.email_outlined,
                                    'Email...'.tr(),
                                    false,
                                    true,
                                    controller: _emailController,
                                  ),
                                  component(
                                    Icons.lock_outline,
                                    'Password...'.tr(),
                                    true,
                                    false,
                                    controller: _passwordController,
                                  ),
                                  // SizedBox(height: size.width * .02),

                                  // Row with Sign Up and Sign In as Doctor buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Sign Up button
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  const PatientSignUpPage()));
                                          // print("Sign Up button pressed");
                                        },
                                        child: Container(
                                          height: size.width / 8,
                                          width: size.width / 3,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: accentColor2.withOpacity(
                                                0.6), // Change to accentColor2
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child:  Text(
                                            'Sign Up'.tr(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Sign In as Doctor button
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          try {
                                            // Read the current type
                                            final typeo = await _secureStorage
                                                .read(key: 'type');
                                            // print('Current type: $typeo');

                                            if (typeo == 'doctors') {
                                              // Forcefully update to patients
                                              await _secureStorage.delete(
                                                  key:
                                                      'type'); // Ensure key is removed
                                              await _secureStorage.write(
                                                  key: 'type',
                                                  value: 'patients');
                                              final updatedType =
                                                  await _secureStorage.read(
                                                      key: 'type');
                                              // ignore: avoid_print
                                              print(
                                                  'Type after update: $updatedType');
                                            } else if (typeo == 'patients') {
                                              // Forcefully update to doctors
                                              await _secureStorage.delete(
                                                  key:
                                                      'type'); // Ensure key is removed
                                              await _secureStorage.write(
                                                  key: 'type',
                                                  value: 'doctors');
                                              final updatedType =
                                                  await _secureStorage.read(
                                                      key: 'type');
                                              // ignore: avoid_print
                                              print(
                                                  'Type after update: $updatedType');
                                            } else {
                                              // Handle unexpected or null value
                                              // ignore: avoid_print
                                              print(
                                                  'Type is null or invalid, defaulting to patients');
                                              await _secureStorage.write(
                                                  key: 'type',
                                                  value: 'patients');
                                              final updatedType =
                                                  await _secureStorage.read(
                                                      key: 'type');
                                              // ignore: avoid_print
                                              print(
                                                  'Type after update: $updatedType');
                                            }

                                            // Navigate to LoginPage
                                            // ignore: use_build_context_synchronously
                                            Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                const LoginPage(),
                                              ),
                                            );
                                          } catch (e) {
                                            // print(
                                            //     'Error during type toggle: $e');
                                          }
                                        },
                                        child: Container(
                                          height: size.width / 8,
                                          width: size.width / 3,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color:
                                                accentColor2.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            currentType == 'doctors'
                                                ? 'Sign In Patient'.tr()
                                                : 'Sign In Doctor'.tr(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: size.width * .1),

                                  // Sign-In button (as before)
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      login();
                                      // print("Login button pressed");
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        bottom: size.width * .05,
                                      ),
                                      height: size.width / 8,
                                      width: size.width / 1.25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: accentColor2.withOpacity(
                                            0.8), // Change to accentColor2
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child:  Text(
                                        'Sign-In'.tr(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: accentColor2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget component(
      IconData icon, String hintText, bool isPassword, bool isEmail,
      {TextEditingController? controller}) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width / 8,
      width: size.width / 1.25,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      decoration: BoxDecoration(
        color: accentColor2.withOpacity(0.6), // Change to accentColor2
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.white.withOpacity(1),
        ),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(1),
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(1),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
