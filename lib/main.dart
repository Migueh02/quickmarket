import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickmarket/firebase_options.dart';
import 'package:quickmarket/presentation/app.dart';

/// Punto de entrada: inicializa Firebase y Riverpod.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('quickmarket_cart_box');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firestore caché offline: $e');
    }
  }
  runApp(
    const ProviderScope(
      child: QuickMarketApp(),
    ),
  );
}
