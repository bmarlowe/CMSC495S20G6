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
      acquisition_date: fields[1] as String,
      expiration_date: fields[3] as String,
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
      ..write(obj.acquisition_date)
      ..writeByte(2)
      ..write(obj.quantity_with_unit)
      ..writeByte(3)
      ..write(obj.expiration_date);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    name: json['name'] as String,
    acquisition_date: json['acquisition_date'] as String,
    expiration_date: json['expiration'] as String,
    quantity_with_unit: json['quantity_with_unit'] as String,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'acquisition_date_date': instance.acquisition_date,
      'quantity_with_unit': instance.quantity_with_unit,
      'expiration_date': instance.expiration_date,
    };
