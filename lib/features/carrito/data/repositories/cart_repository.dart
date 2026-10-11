import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item.dart';

class CartRepository {
  /// Devuelve el nombre de la caja según el user id.
  /// Cada usuario tiene su propia caja: 'cart_box_1', 'cart_box_2', etc.
  String _boxName(int userId) => 'cart_box_$userId';

  Future<Box<CartItem>> _box(int userId) async {
    final name = _boxName(userId);
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<CartItem>(name);
    }
    return Hive.box<CartItem>(name);
  }

  Future<List<CartItem>> getItems(int userId) async {
    final box = await _box(userId);
    return box.values.toList();
  }

  Future<void> add(int userId, CartItem nuevo) async {
    final box = await _box(userId);
    final existente = box.values
        .where((e) => e.productoId == nuevo.productoId)
        .cast<CartItem?>()
        .firstWhere((e) => true, orElse: () => null);

    if (existente != null) {
      existente.cantidad += nuevo.cantidad;
      await existente.save();
    } else {
      await box.add(nuevo);
    }
  }

  Future<void> updateQty(int userId, int productoId, int cantidad) async {
    final box = await _box(userId);
    final item = box.values.firstWhere(
      (e) => e.productoId == productoId,
      orElse: () => throw Exception('Item no encontrado'),
    );
    if (cantidad <= 0) {
      await item.delete();
    } else {
      item.cantidad = cantidad;
      await item.save();
    }
  }

  Future<void> remove(int userId, int productoId) async {
    final box = await _box(userId);
    final item = box.values.firstWhere(
      (e) => e.productoId == productoId,
      orElse: () => throw Exception('Item no encontrado'),
    );
    await item.delete();
  }

  Future<void> clear(int userId) async {
    final box = await _box(userId);
    await box.clear();
  }
}
