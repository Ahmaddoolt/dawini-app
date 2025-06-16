import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IconMedicine extends StatelessWidget {
  const IconMedicine({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; 

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20.0 : 25.0,
        vertical: isSmallScreen ? 15.0 : 20.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: accentColor2, width: 3),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Text(
                'ancient_icon_of_medicine'.tr(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 20.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: accentColor2
                ),
              ),
              SizedBox(
                width: isSmallScreen ? screenWidth * 0.7 : 300,
                height: isSmallScreen ? 150 : 188,
                child: Image.asset(
                  'assets/medic.png',
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8.0 : 16.0,
                ),
                child: Text(
                  'ancient_icon_description'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15.0 : 18.0,
                    color: accentColor2
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
