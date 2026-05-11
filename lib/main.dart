import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ColabMatch()));
}

class ColabMatch extends StatelessWidget {
  const ColabMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColabMatch',
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('ColabMatch'))),
    );
  }
}
