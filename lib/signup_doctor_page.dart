import 'dart:io';
import 'package:dawintesto/login_page.dart';
import 'package:dawintesto/models/static_values.dart';
import 'package:dawintesto/signup_users.dart';
import 'package:dawintesto/user/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DoctorSignUpPageState createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sicknessesController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _imageFile;
  String? selectedSpecialization;
  String? selectedLocation;
  bool _isUploading = false;

  final List<String> genders = ['Male', 'Female'];

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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Sign-up logic
  Future<void> _handleSignUp() async {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        sicknessesController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedSpecialization == null ||
        selectedLocation == null ||
        _imageFile == null ||
        selectedGender == null ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });

    // Upload image to Firebase Storage
    String imageUrl = '';
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('doctor_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_imageFile!);
      imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image upload failed')));
      setState(() {
        _isUploading = false;
      });
      return;
    }

    // Save doctor details to Firestore
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('email', isEqualTo: emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email exists, show an error message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered')),
        );
        setState(() {
          _isUploading = false;
        });
        return; // Stop further execution
      }
      await FirebaseFirestore.instance.collection('doctors').add({
        'name': nameController.text,
        'email': emailController.text,
        'description': descriptionController.text,
        'sicknesses': sicknessesController.text,
        'phone': phoneController.text,
        'gender': selectedGender,
        'specialization': selectedSpecialization,
        'location': selectedLocation,
        'profilePicture': imageUrl,
        'password': passwordController.text,
        'instagram': instagramController.text.isEmpty
            ? 'None'
            : instagramController.text,
        'Active': false
      });

      await _secureStorage.delete(key: 'type');

      await _secureStorage.write(key: 'type', value: 'doctors');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sign-up successful!')));

      // Navigate to the doctor dashboard or another page

      await _secureStorage.write(key: 'email', value: emailController.text);
      await _secureStorage.write(
          key: 'password', value: passwordController.text);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
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
        backgroundColor: accentColor2,
        title:
            const Text('Doctor Sign-Up', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  filled: true,
                  fillColor: mainColor2,
                  prefixIcon: Icon(Icons.wc, color: accentColor2),
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

              // Specialization Dropdown
              DropdownButtonFormField<String>(
                value: selectedSpecialization,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.medical_services, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: specializations.map((specialization) {
                  return DropdownMenuItem<String>(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSpecialization = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Location Dropdown
              DropdownButtonFormField<String>(
                value: selectedLocation,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: arabicCountries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Short Description',
                  prefixIcon: Icon(Icons.description, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sicknesses Treated Field
              TextField(
                controller: sicknessesController,
                decoration: InputDecoration(
                  labelText: 'Sicknesses Treated',
                  prefixIcon: Icon(Icons.healing, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field with Eye Icon
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                  labelText: 'Confirm Password',
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
              TextField(
                controller: instagramController,
                decoration: InputDecoration(
                  labelText: 'Instagram URL (Optional)',
                  prefixIcon: Icon(Icons.link, color: accentColor2),
                  filled: true,
                  fillColor: mainColor2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile Picture Upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: mainColor2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor2),
                  ),
                  child: _imageFile == null
                      ? Center(
                          child: Text(
                            'Tap to upload profile picture',
                            style: TextStyle(color: accentColor2),
                          ),
                        )
                      : Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: accentColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Sign Up'),
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
                              builder: (context) => const PatientSignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign Up as Patient?',
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
                        'Already have an account? Log in',
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
