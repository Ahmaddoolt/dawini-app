import 'package:dawintesto/models/static_values.dart';
import 'package:dawintesto/user/widgets/icon_of_medicine.dart';
import 'package:dawintesto/user/widgets/medic_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ComparePanel extends StatelessWidget {
  const ComparePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: accentColor2,
        centerTitle: true,
        title: Text(
          'Medicine Page'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [IconMedicine(), MedicButtons()],
        ),
      ),
    );
  }
}
