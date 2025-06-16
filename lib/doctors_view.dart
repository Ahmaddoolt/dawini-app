import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final List<String> specializations = [
    'Cardiology',
    'Neurology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Ophthalmology',
    'Gynecology',
    'Urology',
    'General Medicine',
    'Dentistry',
    'ENT',
    'Gastroenterology',
    'Nephrology',
    'Pulmonology',
    'Oncology',
    'Psychiatry',
    'Sports Medicine',
    'Infectious Diseases',
    'Physical Therapy'
  ];

  final List<String> arabicCountries = [
    'Syria',
    'Lebanon',
    'KSA',
    'UAE',
    'Jordan',
    'Egypt',
    'Iraq',
    'Palestine',
    'Kuwait',
    'Oman',
    'Bahrain',
    'Qatar',
    'Yemen',
    'Libya',
    'Sudan',
    'Morocco',
    'Tunisia',
    'Algeria',
    'Mauritania',
  ];

  String? selectedSpecialization;
  String? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Doctors List'.tr()),
        backgroundColor: accentColor2,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  hint:  Text('Select'.tr()),
                  value: selectedSpecialization,
                  items: specializations
                      .map((spec) => DropdownMenuItem(
                            value: spec,
                            child: Text(spec.tr()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialization = value;
                    });
                  },
                ),
                // Expanded(
                //   child: DropdownButton<String>(
                //     hint: const Text('Select'),
                //     value: selectedCountry,
                //     items: arabicCountries
                //         .map((country) => DropdownMenuItem(
                //               value: country,
                //               child: Text(country),
                //             ))
                //         .toList(),
                //     onChanged: (value) {
                //       setState(() {
                //         selectedCountry = value;
                //       });
                //     },
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No doctors found.'.tr()));
                }

                final doctors = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor =
                        doctors[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(doctor['profilePicture']),
                          radius: 30,
                        ),
                        title: Text(
                          doctor['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(doctor['location']),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DoctorDetailsPage(doctor: doctor),
                              ),
                            );
                          },
                        ),
                      ),
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

  Stream<QuerySnapshot> _buildQuery() {
    Query query = FirebaseFirestore.instance
        .collection('doctors')
        .where('Active', isEqualTo: true); // Only fetch active doctors

    if (selectedSpecialization != null) {
      query = query.where('specialization', isEqualTo: selectedSpecialization);
    }
    if (selectedCountry != null) {
      query = query.where('country', isEqualTo: selectedCountry);
    }

    return query.snapshots();
  }
}
