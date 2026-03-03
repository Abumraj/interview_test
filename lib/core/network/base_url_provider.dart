import 'package:flutter_riverpod/flutter_riverpod.dart';

final baseUrlProvider = Provider<String>((ref) {
  return 'https://lagos-water-craft-be.fly.dev/api/v1';
});
