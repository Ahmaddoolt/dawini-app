import 'package:dawintesto/models/static_values.dart';
import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final String imagePath;
  final String textShowing;
  const LoadingSpinner({Key? key, required this.imagePath, required this.textShowing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        color: Colors.white, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/$imagePath', // Path to your loading GIF
              width: width, // Adjust width as needed
              height: 200, 
            ),
            const SizedBox(height: 20), // Space between the spinner and text
            Text(
              textShowing, // Optional loading text
              style: TextStyle(fontSize: 25, color: accentColor2 , fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
