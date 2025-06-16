import 'package:dawintesto/models/static_values.dart';
import 'package:dawintesto/user/view_thedetail_ofalternative.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';

class AlternativeMedicinePage extends StatefulWidget {
  const AlternativeMedicinePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlternativeMedicinePageState createState() =>
      _AlternativeMedicinePageState();
}

class _AlternativeMedicinePageState extends State<AlternativeMedicinePage> {
  List<Map<String, dynamic>> translatedDocuments = [];
  bool isTranslated = false;
  bool isLoading = false;

  Future<void> translateDocuments(List<QueryDocumentSnapshot> documents) async {
    setState(() {
      isLoading = true;
    });

    final translator = GoogleTranslator();
    final translations = await Future.wait(documents.map((doc) async {
      final title = await translator.translate(doc['title'],
          to: context.locale.languageCode);
      final description =
          // ignore: use_build_context_synchronously
          await translator.translate(doc['description'],
              // ignore: use_build_context_synchronously
              to: context.locale.languageCode);
      return {
        'title': title.text,
        'description': description.text,
      };
    }).toList());

    setState(() {
      translatedDocuments = translations;
      isTranslated = true;
      isLoading = false;
    });
  }

  final translator = GoogleTranslator();

  Future<String> _translateText(String text, String targetLang) async {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: const Text('Alternative Medicine').tr(),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('AlternativeMedicine')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No data available.'));
              } else {
                final documents = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10.0 : 16.0),
                  itemCount: isTranslated
                      ? translatedDocuments.length
                      : documents.length,
                  itemBuilder: (context, index) {
                    var document = isTranslated
                        ? translatedDocuments[index]
                        : documents[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      shadowColor: accentColor2.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/medic.png',
                          fit: BoxFit.contain,
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                        title: FutureBuilder<String>(
                          future: _translateText(
                              document['title'], isArabic ? "ar" : "en"),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? document['title'],
                              maxLines: 2, // 🔹 Limit to 2 lines
                              overflow: TextOverflow
                                  .ellipsis, // 🔹 Show "..." if text overflows
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 16 : 18,
                                color: accentColor2,
                              ),
                            );
                          },
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FutureBuilder<String>(
                            future: _translateText(document['description'],
                                isArabic ? "ar" : "en"),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? document['description'],
                                maxLines: 2, // 🔹 Limit to 2 lines
                                overflow: TextOverflow
                                    .ellipsis, // 🔹 Show "..." if text overflows
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: accentColor2,
                                ),
                              );
                            },
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: accentColor2,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AlternativeMedicineDetailPage(
                                      description: document['description'],
                                      title: document['title'],
                                      imagePath: 'yin.gif',
                                    )),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
