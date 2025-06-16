import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileUserPageState createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final email = await _secureStorage.read(key: 'email');
    if (email != null) {
      final query = await _firestore
          .collection('patients')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          userData = query.docs.first.data();
        });
      }
    }
  }

  void _editField(String fieldName, String currentValue) {
    if (fieldName == 'gender') {
      _editDropdownField(
        fieldName: fieldName,
        currentValue: currentValue,
        options: ['Male', 'Female'],
      );
    } else if (fieldName == 'location') {
      _editDropdownField(
        fieldName: fieldName,
        currentValue: currentValue,
        options: [
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
        ],
      );
    } else if (fieldName == 'dateofbirth') {
      _editDateOfBirth(currentValue);
    } else {
      final controller = TextEditingController(text: currentValue);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Text(
                  'Edit:'.tr(),
                  style: TextStyle(color: accentColor2),
                ),
                Text(
                  fieldName.tr(),
                  style: TextStyle(color: accentColor2),
                ),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Enter new $fieldName',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final newValue = controller.text.trim();
                  if (newValue.isNotEmpty) {
                    await _updateField(fieldName, newValue);
                    setState(() {
                      userData![fieldName] = newValue;
                    });
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _editDateOfBirth(String currentValue) async {
    DateTime? selectedDate = DateTime.tryParse(currentValue);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
      await _updateField('dateofbirth', formattedDate);
      setState(() {
        userData!['dateofbirth'] = formattedDate;
      });
    }
  }

  Future<void> _editDropdownField({
    required String fieldName,
    required String currentValue,
    required List<String> options,
  }) async {
    String? selectedValue = currentValue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(
                "Edit:".tr(),
                style: TextStyle(color: accentColor2),
              ),
              Text(
                fieldName.tr(),
                style: TextStyle(color: accentColor2),
              ),
            ],
          ),
          content: DropdownButtonFormField<String>(
            value: selectedValue,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              selectedValue = value;
            },
            decoration: InputDecoration(
              labelText: 'Select $fieldName',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (selectedValue != null && selectedValue != currentValue) {
                  await _updateField(fieldName, selectedValue!);
                  setState(() {
                    userData![fieldName] = selectedValue!;
                  });
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: Text('Save'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateField(String fieldName, String newValue) async {
    final email = await _secureStorage.read(key: 'email');
    if (email != null) {
      setState(() => isLoading = true);

      final query = await _firestore
          .collection('patients')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore.collection('patients').doc(docId).update({
          fieldName: newValue,
        });
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: accentColor2,
          centerTitle: true,
          title: Text('Profile'.tr()),
        ),
        body: Center(
            child: CircularProgressIndicator(
          color: accentColor,
        )),
      );
    }

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: accentColor2,
        centerTitle: true,
        title: Text('Profile'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Icon(Icons.person, size: 130, color: mainColor2),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildEditableRow(
                    icon: Icons.person,
                    label: 'Name',
                    value: userData!['name'],
                  ),
                  _buildEditableRow(
                    icon: Icons.cake,
                    label: 'Date of Birth',
                    value: userData!['dateofbirth'],
                  ),
                  _buildEditableRow(
                    icon: Icons.person_outline,
                    label: 'Gender',
                    value: userData!['gender'],
                  ),
                  _buildEditableRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: userData!['location'],
                  ),
                  _buildEditableRow(
                    icon: Icons.medical_services,
                    label: 'Medical History',
                    value: userData!['medicalhistory'],
                  ),
                  _buildEditableRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: userData!['phone'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: accentColor2),
        title: Text(label.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: accentColor),
          onPressed: () => _editField(
            label.toLowerCase().replaceAll(' ', ''),
            value,
          ),
        ),
      ),
    );
  }
}
