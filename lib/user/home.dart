import 'package:dawintesto/user/widgets/animated_pictures.dart';
import 'package:dawintesto/user/widgets/drawer.dart';
import 'package:dawintesto/user/widgets/listtiles5.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/static_values.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Locale selectedLocale = const Locale('en', 'US'); // Default language

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString('selected_language');
    if (localeString != null) {
      List<String> parts = localeString.split('_');
      setState(() {
        selectedLocale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
      });
    }
  }

  // ignore: unused_element
  // Future<void> _setLanguage(Locale newLocale) async {
  //   await context.setLocale(newLocale); // Set the new locale
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(
  //       'selected_language', newLocale.toString()); // Save to SharedPreferences
  //   setState(() {
  //     selectedLocale = newLocale; // Update the state
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const CustomDrawerUser(),
      backgroundColor: mainColor,
      appBar: AppBar(
        // actions: [
        //   // Language dropdown menu using PopupMenuButton
        //   PopupMenuButton<Locale>(
        //     icon: const Icon(Icons.language, color: Colors.white),
        //     itemBuilder: (BuildContext context) => [
        //       const PopupMenuItem(
        //         value: Locale('en', 'US'),
        //         child: Text('English'),
        //       ),
        //       const PopupMenuItem(
        //         value: Locale('ar', 'AE'),
        //         child: Text('العربية'),
        //       ),
        //     ],
        //     onSelected: (Locale newLocale) {
        //       _setLanguage(newLocale); // Change language
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (context) => SplashScreen()),
        //       );
        //     },
        //   ),
        //   // IconButton(
        //   //   onPressed: () {
        //   //     Navigator.push(
        //   //       context,
        //   //       MaterialPageRoute(builder: (context) => const AdminPanel()),
        //   //     );
        //   //   },
        //   //   icon: Icon(Icons.error, color: mainColor2),
        //   // ),
        // ],
        backgroundColor: accentColor2,
        title: Text(
          'Home Page'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
              width: width,
              height: height * 0.3,
              child: const AnimatedImagesChanger()),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: ListTiles5()),
        ],
      ),
    );
  }
}
