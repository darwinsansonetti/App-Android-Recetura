import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Índice del tab actual del CatalogoShellScreen
/// 0 = Inicio, 1 = Categorías, 2 = Carrito, 3 = Perfil (push, no tab)
final shellTabProvider = StateProvider<int>((_) => 0);
