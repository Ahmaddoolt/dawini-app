import 'package:dawintesto/login_page.dart';
import 'package:dawintesto/signup_doctor_page.dart';
import 'package:dawintesto/user/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/static_values.dart';

class PatientSignUpPage extends StatefulWidget {
  const PatientSignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PatientSignUpPageState createState() => _PatientSignUpPageState();
}

class _PatientSignUpPageState extends State<PatientSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? selectedGender;
  String? selectedLocation;
  bool _isUploading = false;

  final List<String> genders = ['Male', 'Female'];
  final List<String> locations = [
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime initialDate =
        DateTime(currentDate.year - 18, currentDate.month, currentDate.day);
    DateTime firstDate =
        DateTime(currentDate.year - 100, currentDate.month, currentDate.day);
    DateTime lastDate = initialDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        dobController.text.isEmpty ||
        medicalHistoryController.text.isEmpty ||
        selectedGender == null ||
        selectedLocation == null ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please fill in all fields'.tr())),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Passwords do not match'.tr())),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('email', isEqualTo: emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('This email is already registered'.tr())),
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('patients').add({
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'dateofbirth': dobController.text,
        'medicalhistory': medicalHistoryController.text,
        'location': selectedLocation,
        'gender': selectedGender,
        'password':
            passwordController.text, // You might want to hash the password
      });

      await _secureStorage.delete(key: 'type');

      await _secureStorage.write(key: 'type', value: 'patients');

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text('Sign-up successful!'.tr())));

      await _secureStorage.write(key: 'email', value: emailController.text);
      await _secureStorage.write(
          key: 'password', value: passwordController.text);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error signing up')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text('Patient Sign-Up'.tr()),
        centerTitle: true,
        backgroundColor: accentColor2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Full Name Field with Icon
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.person, color: accentColor2),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Dropdown with Icon
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.transgender, color: accentColor2),
                ),
                items: genders.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Phone Field with Icon
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.phone, color: accentColor2),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field with Icon and validation
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address'.tr(),
                  errorText: emailController.text.isNotEmpty &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(emailController.text)
                      ? 'Invalid email address'.tr()
                      : null,
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.email, color: accentColor2),
                ),
              ),
              const SizedBox(height: 16),

              // Date of Birth Field with Date Picker and Icon
              TextField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth'.tr(),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.calendar_today, color: accentColor2),
                    onPressed: () => _selectDate(context),
                  ),
                  filled: true,
                  fillColor: mainColor2,
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Medical History Field with Icon
              TextField(
                controller: medicalHistoryController,
                decoration: InputDecoration(
                  labelText: 'Medical History'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.history, color: accentColor2),
                ),
              ),
              const SizedBox(height: 16),

              // Location Dropdown with Icon
              DropdownButtonFormField<String>(
                value: selectedLocation,
                decoration: InputDecoration(
                  labelText: 'Location'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.location_on, color: accentColor2),
                ),
                items: locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Password Field with Eye Icon
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.lock, color: accentColor2),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: accentColor2,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password Field with Eye Icon
              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password'.tr(),
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.lock, color: accentColor2),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: accentColor2,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign-Up Button
              Center(
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child:  Text(
                          'Sign Up'.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),

              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to the Login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorSignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign Up as Doctor?'.tr(),
                        style: TextStyle(
                            color:
                                accentColor2), // Set the text color to accent color
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the Login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: Text(
                        'Already have an account? Log in'.tr(),
                        style: TextStyle(
                            color:
                                accentColor2), // Set the text color to accent color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
