import 'package:flutter/material.dart';
import 'package:interview/screens/home_screen.dart';
import 'package:interview/screens/widgets/bottom_nav_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int index = 0;

  late final List<Widget> _widgetOption = [
    HomeScreen(),
    const Center(child: Text("Membership Screen")),
    const Center(child: Text("Event Screen")),
    const Center(child: Text("History Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: _widgetOption),

      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}
