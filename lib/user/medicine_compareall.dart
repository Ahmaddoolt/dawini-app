import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CompareAllPage extends StatefulWidget {
  const CompareAllPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompareAllPageState createState() => _CompareAllPageState();
}

class _CompareAllPageState extends State<CompareAllPage> {
  TextEditingController medicineController = TextEditingController();
  List<String> conflictMedicines = [];
  bool isLoading = false;

  void fetchConflictMedicines() async {
    setState(() {
      isLoading = true;
      conflictMedicines = [];
    });

    String medicineName = medicineController.text.trim();

    if (medicineName.isNotEmpty) {
      try {
        // Get the data from Firestore collection 'Medicine'
        final QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('Medicine').get();

        QueryDocumentSnapshot<Map<String, dynamic>>? doc;

        // Look for a document where the medicine name matches, case-insensitive
        try {
          doc = snapshot.docs.firstWhere(
            (doc) {
              final data = doc.data() as Map<String, dynamic>?;
              final medicineData = data?['medicine'] as Map<String, dynamic>?;
              final medicineNameFromDoc =
                  medicineData?['name'] as String? ?? '';
              return medicineNameFromDoc.toLowerCase() ==
                  medicineName.toLowerCase();
            },
          ) as QueryDocumentSnapshot<Map<String, dynamic>>?;
        } on StateError {
          doc = null; // No matching document found
        }

        // If the document is found
        if (doc != null) {
          final data = doc.data();
          final conflictList = data['conflictMedicines'] as List<dynamic>?;

          if (conflictList != null && conflictList.isNotEmpty) {
            setState(() {
              conflictMedicines = conflictList.whereType<String>().toList();
            });

            // Display the dialog based on the conflict found
            if (conflictMedicines.isNotEmpty) {
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/yes2.gif',
                          width: 130,
                          height: 130,
                        ),
                      ],
                    ),
                    content: Text(
                      'Conflict Detected: $medicineName is in conflict with ${conflictMedicines.join(', ')}',
                      style: TextStyle(
                          color: accentColor, fontWeight: FontWeight.bold),
                    ).tr(),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(accentColor),
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
            } else {
              // No conflict found
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/empty2.gif',
                          width: 130,
                          height: 130,
                        ),
                      ],
                    ),
                    content: Text(
                      '$medicineName is not in conflict with any other medicines.',
                      style: TextStyle(
                          color: accentColor2, fontWeight: FontWeight.bold),
                    ).tr(),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  accentColor2),
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
          } else {
            setState(() {
              conflictMedicines = [];
            });

            // Show a dialog when conflictMedicines is empty or invalid
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/not_found2.gif',
                          width: 130,
                          height: 130,
                        ),
                      ],
                    ),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$medicineName is not found',
                          style: TextStyle(
                              color: accentColor2, fontWeight: FontWeight.bold),
                        ).tr(),
                      ],
                    ),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  accentColor2),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK').tr(),
                          ),
                        ],
                      )
                    ]);
              },
            );
          }
        } else {
          setState(() {
            conflictMedicines = [];
          });

          // Handle case where medicine is not found
          // ignore: use_build_context_synchronously
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
                content: Text(
                  'Please Enter The Name Of The Medicine',
                  style: TextStyle(
                      color: accentColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
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
              );
            },
          );
        }
      } catch (e) {
        setState(() {
          conflictMedicines = [];
        });

        // Catch any errors related to Firestore
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
          content: Text(
            'Please Enter The Name Of The Medicine',
            style: TextStyle(
                color: accentColor2, fontWeight: FontWeight.bold, fontSize: 15),
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

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: mainColor2,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: const Text(
          'Medicine Conflict Checker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'assets/medicines.gif',
                    width: isWideScreen ? 450 : 350,
                    height: isWideScreen ? 450 : 350,
                  ),
                ),
                TextField(
                  controller: medicineController,
                  decoration: InputDecoration(
                    labelText: 'Enter Medicine Name'.tr(),
                    labelStyle: TextStyle(color: accentColor2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchConflictMedicines,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Check Conflict'.tr(),
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                if (conflictMedicines.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color.fromARGB(255, 249, 226, 234),
                        Color.fromARGB(255, 251, 229, 255),
                      ]),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: accentColor, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conflict Medicines:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentColor2,
                          ),
                        ).tr(),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    conflictMedicines.take(6).map((medicine) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.widgets,
                                          color: accentColor2,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          medicine,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ).tr(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Second Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: conflictMedicines
                                    .skip(6)
                                    .take(6)
                                    .map((medicine) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.widgets,
                                          color: accentColor2,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          medicine,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ).tr(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Third Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: conflictMedicines
                                    .skip(12)
                                    .take(6)
                                    .map((medicine) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.widgets,
                                          color: accentColor2,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          medicine,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ).tr(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Fourth Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: conflictMedicines
                                    .skip(18)
                                    .take(6)
                                    .map((medicine) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.widgets,
                                          color: accentColor2,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          medicine,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ).tr(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
