import 'package:dawintesto/models/static_values.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'medicine_show.dart';

class MedicineDetail extends StatelessWidget {
  final Medicine singleMed;
  const MedicineDetail({super.key, required this.singleMed});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          singleMed.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: accentColor2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 600 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: screenWidth * 0.85,
                      height: screenWidth * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.9),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          singleMed.imageUrl,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoRow(
                    icon: Icons.label,
                    label: "Name:".tr(),
                    value: singleMed.name,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.description,
                    label: "Description:".tr(),
                    value: singleMed.description,
                    expanded: true,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: 'Type:'.tr(),
                    value: singleMed.type,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.warning, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        'Conflict Medicines:'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (var conflictMedicine in singleMed.conflictMedicines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.mediation, color: accentColor2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              conflictMedicine,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool expanded = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor),
        const SizedBox(width: 8),
        expanded
            ? Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: accentColor2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: accentColor2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      color: accentColor2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: accentColor2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
