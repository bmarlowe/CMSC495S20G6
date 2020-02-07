// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Inventory _$InventoryFromJson(Map<String, dynamic> json) {
  return Inventory(
      name: json['name'] as String,
      acquisition: json['acquisition'] as String,
      unit: json['unit'] as String,
      quantity: json['quantity'] as int,
      expiration: json['expiration'] as String);
}

Map<String, dynamic> _$InventoryToJson(Inventory instance) => <String, dynamic>{
      'name': instance.name,
      'acquisition': instance.acquisition,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'expiration': instance.expiration
    };
