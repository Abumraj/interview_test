import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview/const.dart';
import 'package:interview/core/navigation/route_observer.dart';
import 'package:interview/firebase_options.dart';
import 'package:interview/screens/notification_screen.dart';
import 'package:interview/features/profile/presentation/profile_controller.dart';
import 'package:interview/screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}

void _openNotificationsScreen() {
  final nav = rootNavigatorKey.currentState;
  if (nav == null) return;
  nav.push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Firebase not configured yet: $e');
    }
  }

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {}

  runApp(const ProviderScope(child: MarinaApp()));
}

class MarinaApp extends ConsumerStatefulWidget {
  const MarinaApp({super.key});

  @override
  ConsumerState<MarinaApp> createState() => _MarinaAppState();
}

class _MarinaAppState extends ConsumerState<MarinaApp> {
  bool _fcmInitialized = false;

  void _setupFcmHandlers() {
    if (_fcmInitialized) return;
    _fcmInitialized = true;

    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openNotificationsScreen();
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openNotificationsScreen();
    });

    FirebaseMessaging.onMessage.listen((message) {
      final nav = rootNavigatorKey.currentContext;
      if (nav == null) return;
      final notification = message.notification;
      final title = notification?.title ?? 'Notification';
      final body = notification?.body ?? '';

      showDialog<void>(
        context: nav,
        builder:
            (ctx) => AlertDialog(
              title: Text(title),
              content: body.isEmpty ? null : Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _openNotificationsScreen();
                  },
                  child: const Text('Open'),
                ),
              ],
            ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _setupFcmHandlers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserProfile();
    });
  }

  Future<void> _refreshUserProfile() async {
    try {
      await ref.read(profileControllerProvider.notifier).refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'LWC',
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            fontFamily: 'NotoSansJP',
            fontFamilyFallback: const <String>[
              'Roboto',
              'SF Pro Display',
              'SF Pro Text',
              'Arial',
            ],
            scaffoldBackgroundColor: AppColors.backgroundColor,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
