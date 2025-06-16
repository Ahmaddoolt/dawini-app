import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../models/static_values.dart';

class AnimatedImagesChanger extends StatefulWidget {
  const AnimatedImagesChanger({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedImagesChangerState createState() => _AnimatedImagesChangerState();
}

class _AnimatedImagesChangerState extends State<AnimatedImagesChanger> {
  final Map<String, String> textImageMap = {
    "Prevention is better than cure".tr(): 'https://img.freepik.com/free-photo/international-nurses-day-concept_23-2150204884.jpg?t=st=1734951459~exp=1734955059~hmac=afd6db25715ee019007721314547bbe716ab5aca46e5edfd26d2ba49d8e3e88d&w=1060',
    "Vaccinations play a vital role in preventing many infectious diseases such as measles, chickenpox, and polio"
        .tr(): 'https://th.bing.com/th/id/OIP.72ul407IzJYELNVbgf7TbAHaE8?rs=1&pid=ImgDetMain',
    "The popular saying 'An apple a day keeps the doctor away' is an old proverb that advocates the health benefits of eating apples"
        .tr(): 'https://th.bing.com/th/id/OIP.XQTIaGdpNU9Fh37nKXHcuQHaFj?rs=1&pid=ImgDetMain',
    "Laughter may contribute to increasing lifespan by having a positive impact on physical and mental health"
        .tr(): 'https://th.bing.com/th/id/OIP.T_jVZGg9iubMHtJEpE0WPgHaEC?rs=1&pid=ImgDetMain',
          "Did you know that Ibn Sina was the first to invent medical injections and called them Al-Zarqa".tr() : 'https://www.middleeasteye.net/sites/default/files/images-story/Ibn%20Sina%20WikiMedia.jpg',
          "The normal body temperature range for adults is usually between 36.5 and 37.5 degrees Celsius".tr() : 'https://schpnd.ru/en/wp-content/uploads/temperature-38-without-symptoms-2ghj4mtx.webp'
  };

  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 12), (Timer t) {
      setState(() {
        currentIndex = (currentIndex + 1) % textImageMap.length;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentText = textImageMap.keys.elementAt(currentIndex);
    String currentImage = textImageMap.values.elementAt(currentIndex);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 1, // Display only one item
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mainColor2, // Change the background to gray
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 4, color: accentColor2)),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(width: 2, color: accentColor2)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                currentImage,
                                width: width,
                                height: height * 0.18,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              currentText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
