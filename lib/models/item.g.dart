// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    name: json['name'] as String,
    acquisition_date: json['acquisition_date'] as String,
    expiration_date: json['expiration_date'] as String,
    quantity_with_unit: json['quantity_with_unit'] as String,
    user_id: json['user_id'] as int,
    id: json['id'] as int,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'acquisition_date': instance.acquisition_date,
      'quantity_with_unit': instance.quantity_with_unit,
      'expiration_date': instance.expiration_date,
      'user_id': instance.user_id,
      'id': instance.id,
    };
