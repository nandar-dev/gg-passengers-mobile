import 'package:flutter_riverpod/flutter_riverpod.dart';

final exampleProvider = FutureProvider<String>((ref) async {
  // This is an example provider
  return 'Hello Riverpod';
});
