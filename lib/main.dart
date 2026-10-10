import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  // ← async
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa los datos de fecha para el locale español
  await initializeDateFormatting('es', null); // ← NUEVO

  runApp(const ProviderScope(child: MrReceturaApp()));
}
