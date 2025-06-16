import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawintesto/models/sympols.dart';

// import '../add_sicken.dart';

class Sick {
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  late final List<Symptom> symptoms;
  late final List<Causes> causes;
  late final List<Cure> cure;

  Sick({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.symptoms,
    required this.causes,
    required this.cure,
  });
  factory Sick.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Sick(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? '',
      symptoms: (data['symptoms'] as List<dynamic>)
          .map((symptom) => Symptom(name: symptom['name']))
          .toList(),
      causes: (data['causes'] as List<dynamic>)
          .map((cause) => Causes(name: cause['name']))
          .toList(),
      cure: (data['cure'] as List<dynamic>)
          .map((cure) => Cure(name: cure['name']))
          .toList(),
    );
  }
}
