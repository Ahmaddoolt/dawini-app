import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/static_values.dart';
import '../models/sympols.dart';
import 'package:dawintesto/user/widgets/spinner_loading.dart';

class Symptom {
  final String name;
  Symptom({required this.name});
}

class Sick {
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  final List<Symptom> symptoms;
  final List<Causes> causes;
  final List<Cure> cure;

  Sick({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.symptoms,
    required this.causes,
    required this.cure,
  });
}

class SickDetailPage extends StatefulWidget {
  final String sickId;

  const SickDetailPage({required this.sickId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SickDetailPageState createState() => _SickDetailPageState();
}

class _SickDetailPageState extends State<SickDetailPage> {
  final translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: FutureBuilder<String>(
          future: _translateText('Sickness Detail', isArabic ? "ar" : "en"),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? 'Sickness Detail').tr();
          },
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Sickens')
            .doc(widget.sickId)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 120,
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

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: LoadingSpinner(
                imagePath: "empty.gif",
                textShowing: 'No matching sickness found.'.tr(),
              ),
            );
          }

          var sickData = snapshot.data!.data() as Map<String, dynamic>;
          Sick sick = Sick(
            title: sickData['title'],
            description: sickData['description'],
            imageUrl: sickData['imageUrl'],
            type: sickData['type'],
            symptoms: _parseSymptoms(sickData['symptoms']),
            causes: _parseCauses(sickData['causes']),
            cure: _parseCure(sickData['cure']),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    sick.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: FutureBuilder<String>(
                    future: _translateText(sick.title, isArabic ? "ar" : "en"),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? sick.title,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: accentColor2,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<String>(
                  future:
                      _translateText(sick.description, isArabic ? "ar" : "en"),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? sick.description,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionIconTitle(
                    Icons.category, 'Type', sick.type, isArabic ? "ar" : "en"),
                const SizedBox(height: 20),
                if (sick.causes.isNotEmpty)
                  _buildIconSection(
                      Icons.warning_amber_rounded,
                      'Causes',
                      sick.causes.map((c) => c.name).toList(),
                      isArabic ? "ar" : "en"),
                if (sick.symptoms.isNotEmpty)
                  _buildIconSection(
                      Icons.healing,
                      'Symptoms',
                      sick.symptoms.map((s) => s.name).toList(),
                      isArabic ? "ar" : "en"),
                if (sick.cure.isNotEmpty)
                  _buildIconSection(
                      Icons.local_hospital,
                      'Cure',
                      sick.cure.map((c) => c.name).toList(),
                      isArabic ? "ar" : "en"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionIconTitle(
      IconData icon, String title, String content, String language) {
    return FutureBuilder<String>(
      future: _translateText('$title: $content', language),
      builder: (context, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                snapshot.data ?? '$title: $content',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconSection(
      IconData icon, String title, List<String> items, String language) {
    return FutureBuilder<String>(
      future: _translateText(title, language),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor2),
                const SizedBox(width: 8),
                Text(
                  snapshot.data ?? title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items
                .map(
                  (item) => FutureBuilder<String>(
                    future: _translateText(item, language),
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          '- ${snapshot.data ?? item}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  List<Symptom> _parseSymptoms(List<dynamic> symptomsData) {
    return symptomsData
        .map((symptom) => Symptom(name: symptom['name']))
        .toList();
  }

  List<Causes> _parseCauses(List<dynamic> causesData) {
    return causesData.map((causes) => Causes(name: causes['name'])).toList();
  }

  List<Cure> _parseCure(List<dynamic> cureData) {
    return cureData.map((cure) => Cure(name: cure['name'])).toList();
  }

  Future<String> _translateText(String text, String targetLang) async {
    try {
      final translation = await translator.translate(text, to: targetLang);
      return translation.text;
    } catch (e) {
      return text;
    }
  }
}
