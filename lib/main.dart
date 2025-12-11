import 'package:flutter/material.dart';
import 'package:interview/const.dart';
import 'package:interview/screens/dashboard.dart';
import 'package:interview/screens/home_screen.dart';

void main() {
  runApp(const MarinaApp());
}

class MarinaApp extends StatelessWidget {
  const MarinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SFPro',
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: const Dashboard(),
    );
  }
}
