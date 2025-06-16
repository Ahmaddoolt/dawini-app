import 'package:dawintesto/models/static_values.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

import 'medicine_detail.dart';

// Medicine Model
class Medicine {
  String name;
  String description;
  String type;
  List<String> conflictMedicines;
  String imageUrl; // New field to store image URL

  Medicine({
    required this.name,
    required this.description,
    required this.type,
    required this.conflictMedicines,
    required this.imageUrl,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Medicine(
      name: data['medicine']['name'] ?? '',
      description: data['medicine']['description'] ?? '',
      type: data['medicine']['type'] ?? '',
      conflictMedicines: List<String>.from(data['conflictMedicines'] ?? []),
      imageUrl: data['medicine']['imageUrl'] ??
          '', // Assign imageUrl from Firestore data
    );
  }
}

// Main Widget
class MedicineListAndDetailWidget extends StatefulWidget {
  const MedicineListAndDetailWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MedicineListAndDetailWidgetState createState() =>
      _MedicineListAndDetailWidgetState();
}

class _MedicineListAndDetailWidgetState
    extends State<MedicineListAndDetailWidget> {
  final Stream<QuerySnapshot> _medicineStream =
      FirebaseFirestore.instance.collection('Medicine').snapshots();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: const Text(
          'Medicines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name...".tr(),
                prefixIcon: Icon(Icons.search, color: accentColor2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Medicine List
          Expanded(
            child: StreamBuilder(
              stream: _medicineStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Lottie.asset(
                    'assets/loading.json',
                    width: 200,
                    height: 220,
                    fit: BoxFit.fill,
                  ));
                }

                List<Medicine> medicines = snapshot.data!.docs
                    .map((doc) => Medicine.fromFirestore(doc))
                    .toList();

                // Filter medicines based on search query
                List<Medicine> filteredMedicines = medicines
                    .where((medicine) =>
                        medicine.name.toLowerCase().contains(_searchQuery))
                    .toList();

                return ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      trailing: Icon(
                        Icons.info,
                        color: accentColor2,
                      ),
                      title: Row(
                        children: [
                          Text(
                            'Name:'.tr(),
                            style: TextStyle(
                                color: accentColor2,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                          const SizedBox(width: 5),
                          Text(filteredMedicines[index].name),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Type:'.tr(),
                            style: TextStyle(
                                color: accentColor2,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                          const SizedBox(width: 5),
                          Text(filteredMedicines[index].type),
                        ],
                      ),
                      leading: Container(
                        width: 100, // Set the desired width
                        height: 100, // Set the desired height
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                          border: Border.all(
                              width: 3, color: accentColor2), // Pink border
                          image: DecorationImage(
                            image: NetworkImage(filteredMedicines[index]
                                .imageUrl), // Load image dynamically
                            fit: BoxFit
                                .cover, // Ensures the image covers the container area
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MedicineDetail(
                                    singleMed: filteredMedicines[index],
                                  )),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
