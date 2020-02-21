// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final typeId = 0;

  @override
  Item read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      name: fields[0] as String,
      acquisition: fields[1] as String,
      expiration: fields[3] as String,
      quantity_with_unit: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.acquisition)
      ..writeByte(2)
      ..write(obj.quantity_with_unit)
      ..writeByte(3)
      ..write(obj.expiration);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    name: json['name'] as String,
    acquisition: json['acquisition'] as String,
    expiration: json['expiration'] as String,
    quantity_with_unit: json['quantity_with_unit'] as String,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'acquisition': instance.acquisition,
      'quantity_with_unit': instance.quantity_with_unit,
      'expiration': instance.expiration,
    };
