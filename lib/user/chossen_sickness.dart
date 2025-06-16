import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawintesto/models/static_values.dart';
import 'package:dawintesto/user/sick_detail.dart';
import 'package:dawintesto/user/widgets/spinner_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';

import '../doctor_detail.dart';

class SicknessDetailsPage extends StatefulWidget {
  final List<String> selectedSymptoms;
  final bool isShowingButton;

  const SicknessDetailsPage(
      {Key? key, required this.selectedSymptoms, required this.isShowingButton})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SicknessDetailsPageState createState() => _SicknessDetailsPageState();
}

class _SicknessDetailsPageState extends State<SicknessDetailsPage> {
  Future<String> _translateText(String text, String targetLang) async {
    final translator = GoogleTranslator();
    try {
      final translation = await translator.translate(text, to: targetLang);
      return translation.text;
    } catch (e) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: accentColor2,
        centerTitle: true,
        title: const Text('Sickness Details').tr(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('Sickens').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    Center(
                        child: Lottie.asset(
                      'assets/loading.json',
                      width: 400,
                      height: 400,
                      fit: BoxFit.fill,
                    )),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final documents = snapshot.data!.docs;
              final filteredSicknesses = documents.where((doc) {
                final symptoms = doc['symptoms'] as List<dynamic>;
                final matchCount = widget.selectedSymptoms
                    .where(
                        (symptom) => symptoms.any((s) => s['name'] == symptom))
                    .length;
                return matchCount > 0;
              }).toList()
                ..sort((a, b) {
                  final aMatchCount = widget.selectedSymptoms
                      .where((symptom) => (a['symptoms'] as List<dynamic>)
                          .any((s) => s['name'] == symptom))
                      .length;
                  final bMatchCount = widget.selectedSymptoms
                      .where((symptom) => (b['symptoms'] as List<dynamic>)
                          .any((s) => s['name'] == symptom))
                      .length;
                  return bMatchCount.compareTo(aMatchCount);
                });

              if (filteredSicknesses.isEmpty) {
                return Center(
                  child: LoadingSpinner(
                    imagePath: "empty2.gif",
                    textShowing: 'No matching sickness found.'.tr(),
                  ),
                );
              }

              final firstSickness = filteredSicknesses.first;
              final firstTitle = firstSickness['title'];
              final typeSick = firstSickness['type'];
              final firstDescription = firstSickness['description'];
              final firstImageUrl = firstSickness['imageUrl'];
              final firstCauses = (firstSickness['causes'] as List<dynamic>)
                  .map((cause) => cause['name'] as String)
                  .join(', ');
              final firstSymptoms = (firstSickness['symptoms'] as List<dynamic>)
                  .map((symptom) =>
                      (symptom as Map<String, dynamic>)['name'] as String)
                  .join(', ');
              final firstCure = (firstSickness['cure'] as List<dynamic>)
                  .map((cure) =>
                      (cure as Map<String, dynamic>)['name'] as String)
                  .join(', ');

              return Column(
                children: [
                  if (firstImageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          firstImageUrl as String,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    color: mainColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: FutureBuilder<String>(
                              future: _translateText(
                                  firstTitle as String, isArabic ? "ar" : "en"),
                              builder: (context, snapshot) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.data ?? firstTitle,
                                      style: TextStyle(
                                        color: accentColor2,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          _buildDetailSection(
                            icon: Icons.description,
                            title: 'Description',
                            content: firstDescription,
                            language: isArabic ? "ar" : "en",
                          ),
                          _buildDetailSection(
                            icon: Icons.warning_amber_outlined,
                            title: 'Causes',
                            content: firstCauses,
                            language: isArabic ? "ar" : "en",
                          ),
                          _buildDetailSection(
                            icon: Icons.local_hospital,
                            title: 'Symptoms',
                            content: firstSymptoms,
                            language: isArabic ? "ar" : "en",
                          ),
                          _buildDetailSection(
                            icon: Icons.healing,
                            title: 'Cure',
                            content: firstCure,
                            language: isArabic ? "ar" : "en",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (widget.isShowingButton)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(accentColor2),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return ListView.builder(
                                itemCount: filteredSicknesses.length,
                                itemBuilder: (context, index) {
                                  final doc = filteredSicknesses[index];
                                  final title = doc['title'];
                                  final description = doc['description'];
                                  final imageUrl = doc['imageUrl'];

                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.all(8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ListTile(
                                      trailing: Icon(
                                        Icons.info,
                                        color: accentColor,
                                      ),
                                      leading: imageUrl != null
                                          ? Image.network(imageUrl as String)
                                          : const Icon(
                                              Icons.image_not_supported),
                                      title: FutureBuilder<String>(
                                        future: _translateText(title as String,
                                            isArabic ? "ar" : "en"),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: accentColor2,
                                              fontSize: 20,
                                            ),
                                          );
                                        },
                                      ),
                                      subtitle: Text(description),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SickDetailPage(
                                              sickId: doc.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Show All Matching Sicknesses',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ).tr(),
                      ),
                    ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(accentColor2),
                      ),
                      onPressed: () async {
                        // 1. Fetch all doctors with matching specialization
                        final doctorsSnapshot = await FirebaseFirestore.instance
                            .collection('doctors')
                            .where('specialization', isEqualTo: typeSick)
                            .get();

                        // 2. Filter locally to keep only active doctors (Active == true)
                        final List<Map<String, dynamic>> filteredDoctors =
                            doctorsSnapshot.docs
                                .where((doc) =>
                                    doc['Active'] == true) // <-- Local filter
                                .map((doc) => doc.data())
                                .toList();

                        // 3. Show the filtered doctors in a modal bottom sheet
                        // ignore: use_build_context_synchronously
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            if (filteredDoctors.isEmpty) {
                              return Center(
                                child: Text(
                                  'No active doctors available'.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: accentColor2,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filteredDoctors.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDoctors[index];
                                final title = doc['name'];
                                final description = doc['gender'];
                                final imageUrl = doc['profilePicture'];

                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    trailing:
                                        Icon(Icons.info, color: accentColor),
                                    leading: imageUrl != null
                                        ? Image.network(imageUrl as String)
                                        : const Icon(Icons.image_not_supported),
                                    title: FutureBuilder<String>(
                                      future: _translateText(title as String,
                                          isArabic ? "ar" : "en"),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: accentColor2,
                                            fontSize: 20,
                                          ),
                                        );
                                      },
                                    ),
                                    subtitle: Text(description),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDetailsPage(doctor: doc),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        'Doctors for consultation'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ).tr(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
      {required IconData icon,
      required String title,
      required String content,
      required String language}) {
    return FutureBuilder<String>(
      future: _translateText(content, language),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  color: accentColor2,
                  size: 23,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(snapshot.data ?? content),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
