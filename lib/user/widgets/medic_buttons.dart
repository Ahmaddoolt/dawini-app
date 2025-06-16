import 'package:dawintesto/models/static_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:easy_localization/easy_localization.dart'; // Import EasyLocalization

import '../medicine_compare.dart';
import '../medicine_compareall.dart';
import '../medicine_show.dart';

class MedicButtons extends StatelessWidget {
  const MedicButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // Adjust the threshold as needed

    // Determine if the current language is Arabic
    bool isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AnimationLimiter(
        child: Wrap(
          spacing: 20, // Horizontal spacing between buttons
          runSpacing: 20, // Vertical spacing between rows
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildAnimatedButton(
                context,
                icon: Icons.medical_services,
                title: 'Info of Medicine'.tr(),
                subtitle: 'Get detailed information about a medicine'.tr(),
                onTap: () => _navigateToPage(context, const MedicineListAndDetailWidget()),
                width: isWideScreen ? (screenWidth / 2) - 30 : screenWidth - 40,
                isArabic: isArabic, // Pass isArabic to the button
              ),
              _buildAnimatedButton(
                context,
                icon: Icons.compare,
                title: 'Compare 2 Medicines'.tr(),
                subtitle: 'Check if medicine 2 can conflict with medicine 1'.tr(),
                onTap: () => _navigateToPage(context, const CompareMedicinePage()),
                width: isWideScreen ? (screenWidth / 2) - 30 : screenWidth - 40,
                isArabic: isArabic, // Pass isArabic to the button
              ),
              _buildAnimatedButton(
                context,
                icon: Icons.warning,
                title: 'Compare Medicine with All'.tr(),
                subtitle: 'View the conflict of this medicine'.tr(),
                onTap: () => _navigateToPage(context, const CompareAllPage()),
                width: isWideScreen ? (screenWidth / 2) - 30 : screenWidth - 40,
                isArabic: isArabic, // Pass isArabic to the button
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      required double width,
      required bool isArabic}) { // Added isArabic parameter
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor2,
              mainColor,
              accentColor,
            ],
            begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
          ),
          border: Border.all(width: 3, color: accentColor2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: accentColor2.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: accentColor2,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: accentColor2.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
