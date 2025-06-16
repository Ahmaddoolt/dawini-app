import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/static_values.dart';

class DoctorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsPage({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(doctor['name'], style: TextStyle(color: mainColor2)),
        backgroundColor: accentColor2,
        iconTheme: IconThemeData(color: mainColor2),
        elevation: 0,
      ),
      body: Container(
        color: mainColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(doctor['profilePicture']),
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                color: mainColor2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: accentColor2),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['name'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: accentColor2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.wc, color: Colors.orange),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['gender'].toString().tr(),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: accentColor2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.redAccent),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['location'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['phone'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['specialization'].toString().tr(),
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.sick, color: Colors.deepPurple),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['sicknesses'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.link, color: Colors.pinkAccent),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                String text = doctor['instagram'];
                                final url = text.startsWith('http')
                                    ? text
                                    : 'https://$text';

                                final uri = Uri.tryParse(url);
                                // print("Trying to launch URL: $url");

                                if (uri != null) {
                                  // Check if the URL can be launched
                                  bool canLaunch = await canLaunchUrl(uri);
                                  // print("Can launch URL: $canLaunch");

                                  if (canLaunch) {
                                    // Launch the URL in the in-app web view
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    // Show a Snackbar if the URL cannot be launched
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Could not open the link: $url')),
                                    );
                                  }
                                } else {
                                  // Handle invalid URL format
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Invalid URL format')),
                                  );
                                }
                              },
                              child: Text(
                                doctor['sicknesses'] == 'None'
                                    ? "None"
                                    : "Instagram Account",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blue[300],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.blueGrey),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              doctor['description'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
