import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/screens/event_screen.dart';
import 'package:interview/screens/history_screen.dart';
import 'package:interview/screens/home_screen.dart';
import 'package:interview/screens/login_screen.dart';
import 'package:interview/screens/signin_screen.dart';
import 'package:interview/screens/widgets/bottom_nav_bar.dart';
import 'package:interview/core/network/core_network_providers.dart';
import 'package:interview/features/auth/presentation/auth_controller.dart';
import 'package:interview/utils/page_transitions.dart';
import 'package:interview/const.dart';

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
    final userId = ref.watch(authControllerProvider).value?.user?.id ?? '';

    Future<void> showAuthRequired() async {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: AppColors.subcolor,
            title: const Text(
              'Login required',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Please login or create an account to continue.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(
                    context,
                  ).push(SlideRightRoute(page: const SigninScreen()));
                },
                child: const Text(
                  'Proceed',
                  style: TextStyle(color: AppColors.lightBlue),
                ),
              ),
            ],
          );
        },
      );
    }

    ref.listen<int>(unauthorizedEventProvider, (previous, next) {
      final prev = previous ?? 0;
      if (next <= prev) return;
      if (!mounted) return;

      final currentUserId =
          ref.read(authControllerProvider).value?.user?.id ?? '';
      if (currentUserId.isEmpty) return;

      Navigator.of(context).pushAndRemoveUntil(
        FadeScaleRoute(page: const LoginScreen()),
        (route) => false,
      );
    });

    return Scaffold(
      body: IndexedStack(index: index, children: _widgetOption),

      bottomNavigationBar: BottomNavBar(
        currentIndex: index,
        onTap: (i) {
          if (i != 0 && userId.isEmpty) {
            showAuthRequired();
            return;
          }
          setState(() => index = i);
        },
      ),
    );
  }
}
