import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawintesto/user/sick_detail.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';

import '../models/static_values.dart';

class SiknessPage extends StatefulWidget {
  const SiknessPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SiknessPageState createState() => _SiknessPageState();
}

class _SiknessPageState extends State<SiknessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _dataList = [];
  List<Map<String, dynamic>> _filteredDataList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    fetchDataFromFirestore();

    _controller.forward();
  }

  void fetchDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Sickens').get();
      setState(() {
        _dataList = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        _filteredDataList = List.from(_dataList);
      });
    } catch (e) {
      // print('Error fetching data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterData(String query) {
    setState(() {
      _filteredDataList = _dataList.where((item) {
        final title = item['title'].toString().toLowerCase();
        final type = item['type'].toString().toLowerCase();
        return title.contains(query.toLowerCase()) ||
            type.contains(query.toLowerCase());
      }).toList();
    });
  }

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
    double width = MediaQuery.of(context).size.width;
    bool isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: accentColor2,
        title: const Text(
          'Diseases',
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
      // backgroundColor: mainColor2,
      body: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          searchBar(),
          SizedBox(height: width / 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: width / 20,
              childAspectRatio: 2 / 2.6,
            ),
            itemCount: _filteredDataList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SickDetailPage(
                          sickId: _filteredDataList[index]['id'],
                        ),
                      ),
                    );
                  },
                  child: FutureBuilder(
                    future: Future.wait([
                      _translateText(_filteredDataList[index]['title'],
                          isArabic ? "ar" : "en"),
                      _translateText(_filteredDataList[index]['type'],
                          isArabic ? "ar" : "en"),
                    ]),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          
                            Center(
                                child: Lottie.asset(
                              'assets/loading.json',
                              width: 200,
                              height: 220,
                              fit: BoxFit.fill,
                            )),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return card(
                          _filteredDataList[index]['title'],
                          _filteredDataList[index]['type'],
                          _filteredDataList[index]['imageUrl'],
                        );
                      } else {
                        return card(
                          snapshot.data![0],
                          snapshot.data![1],
                          _filteredDataList[index]['imageUrl'],
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.fromLTRB(width / 20, width / 25, width / 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: width / 8.5,
                width: width / 1.36,
                padding: EdgeInsets.symmetric(horizontal: width / 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  maxLines: 1,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    filled: true,
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(.4),
                      fontWeight: FontWeight.w600,
                      fontSize: width / 22,
                    ),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.black.withOpacity(.6)),
                    hintText: 'search_hint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget card(String title, String subtitle, String image) {
    double width = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: _animation.value,
      child: Container(
        decoration: BoxDecoration(
          color: mainColor2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor2, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 50),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: width / 2.6,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: width / 2.36,
                  height: width / 2.6,
                ),
              ),
            ),
            Container(
              height: width / 6,
              padding: EdgeInsets.symmetric(horizontal: width / 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textScaleFactor: 1.4,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: accentColor2, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    textScaleFactor: 1,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
