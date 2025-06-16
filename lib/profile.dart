import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models/static_values.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;
  Map<String, dynamic>? doctor;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _imageFile;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
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

  final List<String> specializations = [
    'Physical diseases',
    'Mental illness',
    'Psychiatric illness',
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
    'Gum diseases',
    'Oral and maxillofacial surgery',
    'Ear, nose, and throat (ENT)',
    'Liver and gastrointestinal diseases',
    'Kidney diseases',
    'Respiratory diseases',
    'Internal medicine',
    'Sports medicine',
    'Infectious diseases',
    'Oncology',
    'Physical therapy',
    'Immunological diseases',
    'Child and adolescent psychiatry'
  ];

 final List<String> genders = [
    'Male',
    'Female',
  ];


  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    final email = await _secureStorage.read(key: 'email');
    // print("eeeeeeeeeeeeeeeeeeeeeeee ====${email}");
    if (email != null) {
      final doc = await _firestore
          .collection('doctors')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        setState(() {
          doctor = doc.docs.first.data();
        });
      }
    }
  }

  void _editField(String fieldName, String currentValue) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);
    final email = await _secureStorage.read(key: 'email');
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: fieldName == 'location'
              ? DropdownButton<String>(
                  value: currentValue,
                  isExpanded: true,
                  items: arabicCountries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != currentValue) {
                      if (email != null) {
                        setState(() {
                          isLoading = true; // Show loading indicator
                        });
                        try {
                          final querySnapshot = await _firestore
                              .collection('doctors')
                              .where('email', isEqualTo: email)
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            final docId = querySnapshot.docs.first.id;
                            await _firestore
                                .collection('doctors')
                                .doc(docId)
                                .update({fieldName: newValue});

                            setState(() {
                              doctor![fieldName] = newValue;
                              currentValue = newValue;
                            });
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          } else {
                            // print('No document found for the given email');
                          }
                        } catch (e) {
                          // print('Error updating $fieldName: $e');
                        } finally {
                          setState(() {
                            isLoading = false; // Hide loading indicator
                          });
                        }
                      }
                    }
                  },
                )
              : fieldName == 'gender' ?
              DropdownButton<String>(
                      value: currentValue,
                      isExpanded: true,
                      items: genders.map((country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null && newValue != currentValue) {
                          if (email != null) {
                            setState(() {
                              isLoading = true; // Show loading indicator
                            });
                            try {
                              final querySnapshot = await _firestore
                                  .collection('doctors')
                                  .where('email', isEqualTo: email)
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                final docId = querySnapshot.docs.first.id;
                                await _firestore
                                    .collection('doctors')
                                    .doc(docId)
                                    .update({fieldName: newValue});

                                setState(() {
                                  doctor![fieldName] = newValue;
                                  currentValue = newValue;
                                });
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              } else {
                                // print('No document found for the given email');
                              }
                            } catch (e) {
                              // print('Error updating $fieldName: $e');
                            } finally {
                              setState(() {
                                isLoading = false; // Hide loading indicator
                              });
                            }
                          }
                        }
                      },
                    )
              
              :
              fieldName == 'specialization'
                  ? DropdownButton<String>(
                      value: currentValue,
                      isExpanded: true,
                      items: specializations.map((country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null && newValue != currentValue) {
                          if (email != null) {
                            setState(() {
                              isLoading = true; // Show loading indicator
                            });
                            try {
                              final querySnapshot = await _firestore
                                  .collection('doctors')
                                  .where('email', isEqualTo: email)
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                final docId = querySnapshot.docs.first.id;
                                await _firestore
                                    .collection('doctors')
                                    .doc(docId)
                                    .update({fieldName: newValue});

                                setState(() {
                                  doctor![fieldName] = newValue;
                                  currentValue = newValue;
                                });
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              } else {
                                // print('No document found for the given email');
                              }
                            } catch (e) {
                              // print('Error updating $fieldName: $e');
                            } finally {
                              setState(() {
                                isLoading = false; // Hide loading indicator
                              });
                            }
                          }
                        }
                      },
                    )
                  : TextField(
                      controller: controller,
                      decoration:
                          InputDecoration(hintText: 'Enter new $fieldName'),
                    ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (fieldName !=
                'Location') // Only show Save for non-dropdown fields
              TextButton(
                onPressed: () async {
                  final newValue = controller.text.trim();
                  if (newValue.isNotEmpty && email != null) {
                    setState(() {
                      isLoading = true; // Show loading indicator
                    });
                    try {
                      final querySnapshot = await _firestore
                          .collection('doctors')
                          .where('email', isEqualTo: email)
                          .get();

                      if (querySnapshot.docs.isNotEmpty) {
                        final docId = querySnapshot.docs.first.id;
                        await _firestore
                            .collection('doctors')
                            .doc(docId)
                            .update({fieldName: newValue});

                        setState(() {
                          doctor![fieldName] = newValue;
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } else {
                        // print('No document found for the given email');
                      }
                    } catch (e) {
                      // print('Error updating field: $e');
                    } finally {
                      setState(() {
                        isLoading = false; // Hide loading indicator
                      });
                    }
                  }
                },
                child: const Text('Save'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      if (doctor != null) {
        // Simulate uploading image and updating Firestore
        await _firestore
            .collection('doctors')
            .doc(doctor!['id'])
            .update({'profilePicture': pickedFile.path});
        setState(() {
          doctor!['profilePicture'] = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (doctor == null) {
      return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Doctor Details', style: TextStyle(color: mainColor2)),
          backgroundColor: accentColor2,
          iconTheme: IconThemeData(color: mainColor2),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(doctor!['name'], style: TextStyle(color: mainColor2)),
        backgroundColor: accentColor2,
        iconTheme: IconThemeData(color: mainColor2),
        elevation: 0,
      ),
      body: Container(
        color: mainColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(doctor!['profilePicture'])
                            as ImageProvider,
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                color: mainColor2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableRow('Name', doctor!['name'], Icons.person),
                      _buildEditableRow(
                        'Gender',
                        doctor!['gender'],
                        Icons.wc,
                      ),
                      _buildEditableRow(
                          'Location', doctor!['location'], Icons.location_on),
                      _buildEditableRow('Phone', doctor!['phone'], Icons.phone),
                      _buildEditableRow('Specialization',
                          doctor!['specialization'], Icons.stars),
                      _buildEditableRow(
                          'Sicknesses', doctor!['sicknesses'], Icons.sick),
                      _buildEditableRow('Description', doctor!['description'],
                          Icons.description),
                      _buildEditableLinkRow(
                          'Instagram', doctor!['instagram'], Icons.link),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableRow(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: accentColor2),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[800],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: accentColor),
              onPressed: () => _editField(label.toLowerCase(), value),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildEditableLinkRow(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.pinkAccent),
            const SizedBox(width: 8.0),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(value);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open the link')),
                    );
                  }
                },
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue[300],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: accentColor),
              onPressed: () => _editField(label.toLowerCase(), value),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
