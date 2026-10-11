// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      productoId: fields[0] as int,
      nombre: fields[1] as String,
      slug: fields[2] as String,
      precio: fields[3] as double,
      precioUnitario: fields[4] as double,
      precioEspecial: fields[5] as double?,
      aplicaPrecioEspecial: fields[6] as bool,
      cantidad: fields[7] as int,
      imagen: fields[8] as String?,
      presentacion: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.productoId)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.precio)
      ..writeByte(4)
      ..write(obj.precioUnitario)
      ..writeByte(5)
      ..write(obj.precioEspecial)
      ..writeByte(6)
      ..write(obj.aplicaPrecioEspecial)
      ..writeByte(7)
      ..write(obj.cantidad)
      ..writeByte(8)
      ..write(obj.imagen)
      ..writeByte(9)
      ..write(obj.presentacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
