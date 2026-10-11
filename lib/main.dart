import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'features/carrito/data/models/cart_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CartItemAdapter());

  // Inicializar intl en español
  await initializeDateFormatting('es', null);

  runApp(const ProviderScope(child: MrReceturaApp()));
}
