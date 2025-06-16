import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompareMedicinePage extends StatefulWidget {
  const CompareMedicinePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompareMedicinePageState createState() => _CompareMedicinePageState();
}

class _CompareMedicinePageState extends State<CompareMedicinePage> {
  TextEditingController medicine1Controller = TextEditingController();
  TextEditingController medicine2Controller = TextEditingController();
  List<String> conflictMedicines = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: mainColor2,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: const Text('Medicine Conflict Checker').tr(),
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
                    'assets/compare2.gif',
                    width: 400,
                    height: 400,
                  ),
                ),
                TextField(
                  controller: medicine1Controller,
                  decoration: InputDecoration(
                    labelText: 'Medicine 1'.tr(),
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
                const SizedBox(height: 16),
                TextField(
                  controller: medicine2Controller,
                  decoration: InputDecoration(
                    labelText: 'Medicine 2'.tr(),
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
                  onPressed: searchConflictMedicines,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: accentColor, width: 2.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: Text(
                    'Check Conflict'.tr(),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                if (conflictMedicines.isNotEmpty)
                  Text(
                    'Conflict Medicines for ${medicine1Controller.text}: ${conflictMedicines.join(', ')}',
                    style: TextStyle(
                        fontSize: 16,
                        color: accentColor,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void searchConflictMedicines() async {
    String medicine1Name = medicine1Controller.text.trim();
    String medicine2Name = medicine2Controller.text.trim();

    if (medicine1Name.isNotEmpty && medicine2Name.isNotEmpty) {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Medicine').get();

      QueryDocumentSnapshot<Map<String, dynamic>>? doc;

      try {
        doc = snapshot.docs.firstWhere(
          (doc) =>
              ((doc.data() as Map<String, dynamic>)['medicine']?['name'] ?? '')
                  .toLowerCase() ==
              medicine1Name.toLowerCase(),
        ) as QueryDocumentSnapshot<Map<String, dynamic>>?;
      } catch (e) {
        doc = null;
      }

      if (doc != null) {
        final data = doc.data();
        if (data['conflictMedicines'] != null &&
            data['conflictMedicines'] is List) {
          setState(() {
            conflictMedicines = List<String>.from(data['conflictMedicines']);
          });
        } else {
          setState(() {
            conflictMedicines = [];
          });
        }

        if (conflictMedicines
            .map((e) => e.toLowerCase())
            .contains(medicine2Name.toLowerCase())) {
          // Conflict detected
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
                  'Conflict Detected : $medicine2Name is in conflict with $medicine1Name',
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
          // No conflict
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
                  '$medicine2Name is not in conflict with $medicine1Name',
                  style: TextStyle(
                      color: accentColor2, fontWeight: FontWeight.bold),
                ).tr(),
                actions: <Widget>[
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
      } else {
        setState(() {
          conflictMedicines = [];
        });

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
                    '$medicine1Name is not found',
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
              )
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
  }

}
