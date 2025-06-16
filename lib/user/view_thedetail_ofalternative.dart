import 'package:dawintesto/models/static_values.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:translator/translator.dart';

class AlternativeMedicineDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;

  const AlternativeMedicineDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<AlternativeMedicineDetailPage> createState() =>
      _AlternativeMedicineDetailPageState();
}

class _AlternativeMedicineDetailPageState
    extends State<AlternativeMedicineDetailPage> {
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
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    bool isSmallScreen = width < 600;
    bool isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          ('Details').tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with title
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              decoration: BoxDecoration(
                color: accentColor2,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FutureBuilder<String>(
                      future:
                          _translateText(widget.title, isArabic ? "ar" : "en"),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ??
                              widget.title, // ✅ Fix: Use snapshot.data
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 22 : 28,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      ('Explore detailed information').tr(),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Description Section
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr('Description'),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FutureBuilder<String>(
                        future: _translateText(
                            widget.description, isArabic ? "ar" : "en"),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ??
                                widget.description, // ✅ Fix: Use snapshot.data
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 22 : 28,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Image Section
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.0 : 20.0),
            //   child: Image.asset(
            //     'assets/$imagePath',
            //     width: isSmallScreen ? width * 0.8 : width * 0.75,
            //     height: height * (isSmallScreen ? 0.4 : 0.5),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
