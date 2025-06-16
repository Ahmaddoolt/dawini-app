import 'package:dawintesto/models/static_values.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'chossen_sickness.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SymptomPageState createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitialDialog();
    });
  }

  Future<void> _showInitialDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber,
              color: accentColor2,
              size: 75,
            )
          ],
        ),
        content: Text(
          'The displayed sickness information is based on the symptoms you selected and may not be 100% accurate. For a precise diagnosis, it is essential to consult a doctor and undergo proper testing and analysis.',
          style: TextStyle(color: accentColor2, fontWeight: FontWeight.bold),
        ).tr(),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(accentColor2),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK').tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> allSymptoms = [
    'Coughing',
    'Wheezing',
    'Shortness of breath',
    'Fever',
    'Chest pain or tightness',
    'Sore throat',
    'Nasal congestion',
    'Dizziness',
    'Headaches',
    'Joint pain',
    'Fatigue',
    'Chills',
    'Sweating',
    'Runny nose',
    'Loss of appetite',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Abdominal pain',
    'Muscle pain',
    'Swollen glands',
    'Rash',
    'Itchy skin',
    'Weight loss',
    'Weight gain',
    'Palpitations',
    'Difficulty swallowing',
    'Hoarseness',
    'Frequent urination',
    'Night sweats',
    'Memory loss',
    'Confusion',
    'Difficulty concentrating',
    'Mood swings',
    'Depression',
    'Anxiety',
    'Seizures',
    'Tingling sensations',
    'Vision problems',
    'Speech difficulties',
  ];

  List<String> selectedSymptoms = [];

  void updateSelectedSymptoms(String symptom, bool isChecked) {
    setState(() {
      if (isChecked) {
        if (selectedSymptoms.length >= 8) {
          _showMaxLimitDialog(); // Show warning dialog
          return;
        }
        selectedSymptoms.add(symptom);
      } else {
        selectedSymptoms.remove(symptom);
      }
    });
  }

  void _showMaxLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber,
                color: accentColor2,
                size: 75,
              ),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You can select up to 8 symptoms only.'.tr(),
                style: TextStyle(
                    color: accentColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(accentColor2),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK').tr(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: accentColor2,
        centerTitle: true,
        title: const Text('Select Symptoms').tr(),
      ),
      body: ListView(
        children: allSymptoms.map((symptom) {
          return CheckboxListTile(

            checkColor: accentColor2,
            activeColor: accentColor,
            title: Text(
              symptom,
              style:
                  TextStyle(color: accentColor2, fontWeight: FontWeight.bold),
            ).tr(),
            value: selectedSymptoms.contains(symptom),
            onChanged: (bool? isChecked) {
              updateSelectedSymptoms(symptom, isChecked!);
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor2,
        onPressed: () async {
          if (selectedSymptoms.length >= 3) {
            // Navigate to SicknessDetailsPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SicknessDetailsPage(
                  selectedSymptoms: selectedSymptoms,
                  isShowingButton: true,
                ),
              ),
            );
          } else {
            // Show dialog if fewer than 3 symptoms are selected
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: accentColor2,
                        size: 75,
                      )
                    ],
                  ),
                  content: Text(
                    'Please select at least 3 symptoms to proceed.'.tr(),
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ).tr(),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(accentColor2),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK').tr(),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Icon(
          Icons.search,
        ),
      ),
    );
  }
}
