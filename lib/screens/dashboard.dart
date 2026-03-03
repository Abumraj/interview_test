import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/screens/event_screen.dart';
import 'package:interview/screens/history_screen.dart';
import 'package:interview/screens/home_screen.dart';
import 'package:interview/screens/login_screen.dart';
import 'package:interview/screens/widgets/bottom_nav_bar.dart';
import 'package:interview/core/network/core_network_providers.dart';
import 'package:interview/utils/page_transitions.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int index = 0;

  late final List<Widget> _widgetOption = [
    HomeScreen(),
    const Center(
      child: Text("Coming Soon", style: TextStyle(color: Colors.white)),
    ),
    EventScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(unauthorizedEventProvider, (previous, next) {
      final prev = previous ?? 0;
      if (next <= prev) return;
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        FadeScaleRoute(page: const LoginScreen()),
        (route) => false,
      );
    });

    return Scaffold(
      body: IndexedStack(index: index, children: _widgetOption),

      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}
