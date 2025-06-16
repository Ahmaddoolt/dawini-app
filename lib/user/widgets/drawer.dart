import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_alarm_page.dart';
import '../../animation/splash.dart';
import '../../login_page.dart';
import '../../models/static_values.dart';
import '../../profile.dart';
import '../../profile_user.dart';

class CustomDrawerUser extends StatefulWidget {
  const CustomDrawerUser({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDrawerUser> createState() => _CustomDrawerUserState();
}

class _CustomDrawerUserState extends State<CustomDrawerUser> {
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  Locale selectedLocale = const Locale('en', 'US'); // Default language
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<void> _setLanguage(Locale newLocale) async {
    await context.setLocale(newLocale); // Set the new locale
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selected_language', newLocale.toString()); // Save to SharedPreferences
    setState(() {
      selectedLocale = newLocale; // Update the state
    });
  }

  Future<void> signOut(BuildContext context) async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');

    // await _auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: mainColor,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.monitor_heart,
                    color: accentColor2,
                    size: 135,
                  ),

                  // child: Image.asset(
                  //   'assets/1024.png',
                  //   width: 150,
                  //   height: 180,
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.home,
                    color: accentColor2,
                  ),
                ),
                title: Text(
                  'Home'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor2,
                      fontSize: 18),
                ),
                onTap: () {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const Login(),
                  //     ));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.alarm,
                    color: accentColor2,
                  ),
                ),
                title: Text(
                  'Medicine Alarm'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor2,
                      fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlarmPage(),
                      ));
                },
              ),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.account_box,
                    color: accentColor2,
                  ),
                ),
                title: Text(
                  'Profile'.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor2,
                      fontSize: 18),
                ),
                onTap: () async {
                  // print(widget.typeLog);
                  final typeo = await _secureStorage.read(key: 'type');
                  if (typeo == "doctors") {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()));
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileUserPage()));
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 0, left: 15, top: 0, right: 15),
                    child: Icon(
                      Icons.language,
                      color: accentColor2,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Language'.tr(),
                      style: TextStyle(
                        color: accentColor2,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  PopupMenuButton<Locale>(
                    icon: Icon(Icons.arrow_drop_down, color: accentColor2),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: Locale('en', 'US'),
                        child: Text('English'),
                      ),
                      const PopupMenuItem(
                        value: Locale('ar', 'AE'),
                        child: Text('العربية'),
                      ),
                    ],
                    onSelected: (Locale newLocale) {
                      _setLanguage(newLocale); // Change language
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
                title:  Text(
                  'Logout'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 18),
                ),
                onTap: () {
                  signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
