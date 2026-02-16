import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
    
      
      const SadakApp(),
    
  );
}

class SadakApp extends ConsumerWidget {
  const SadakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   

    return MaterialApp.router(
      title: 'Sadak',
      debugShowCheckedModeBanner: false,
      
    );
  }
}
