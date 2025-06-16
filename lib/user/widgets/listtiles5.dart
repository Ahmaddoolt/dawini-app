import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../doctors_view.dart';
import '../alternativ_medic.dart';
import '../medicalculture.dart';
import '../medicine_panel.dart';
import '../sick_page.dart';
import '../symptons_page.dart';

class ListTiles5 extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'title': 'Symptoms'.tr(),
      'icon': Icons.sick,
      'page': const SymptomPage(),
      'image': 'https://th.bing.com/th/id/R.84786ceb39b4467a742ba3bad347000d?rik=3%2fYzjfxW%2foOYXA&pid=ImgRaw&r=0',
    },
    {
      'title': 'Diseases'.tr(),
      'icon': Icons.coronavirus,
      'page': const SiknessPage(),
      'image': 'https://th.bing.com/th/id/OIP.9dpA7fw8TUsPK6hTeyvOaQHaEK?rs=1&pid=ImgDetMain',
    },
    {
      'title': 'Medication'.tr(),
      'icon': Icons.medication,
      'page': const ComparePanel(),
      'image': 'https://th.bing.com/th/id/R.460bde7558b5b1e38570d292df228fe1?rik=MJF2xsGrXkUVEQ&pid=ImgRaw&r=0',
    },
    {
      'title': 'Alternative Medicine'.tr(),
      'icon': Icons.healing,
      'page': const AlternativeMedicinePage(),
      'image': 'https://th.bing.com/th/id/OIP.ByKJTUPUjrt_XdRjFpQXGgHaEK?rs=1&pid=ImgDetMain',
    },
    {
      'title': 'Medical Culture'.tr(),
      'icon': Icons.book,
      'page': const MedicalCulturePage(),
      'image': 'https://img.freepik.com/free-photo/international-nurses-day-concept_23-2150204884.jpg?t=st=1734951459~exp=1734955059~hmac=afd6db25715ee019007721314547bbe716ab5aca46e5edfd26d2ba49d8e3e88d&w=1060',
    },
    {
      'title': 'Doctors'.tr(),
      'icon': Icons.vaccines,
      'page': const DoctorsListPage(),
      'image':
          'https://thumbs.dreamstime.com/b/portrait-attractive-stylish-doc-stubble-white-lab-coat-tie-stethoscope-his-neck-having-his-arms-portrait-272359796.jpg',
    },
  ];

  ListTiles5({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 2.5, // Adjust the grid item size
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => items[index]['page'],
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(items[index]['image']), // Background image
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  // Add a dark border here
                  color: accentColor2, // Darker border color
                  width: 4, // Border width
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      mainColor2.withOpacity(0.2), // Gradient top
                      mainColor2.withOpacity(0.3), // Gradient top
                      mainColor2.withOpacity(0.3), // Gradient top

                      mainColor2.withOpacity(0.8), // Gradient bottom
                      accentColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[index]['icon'], size: 50, color: Colors.transparent.withOpacity(0.3)),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['title'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 4, 33, 91),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
