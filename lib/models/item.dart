import 'package:json_annotation/json_annotation.dart';
part 'item.g.dart';

@JsonSerializable()
class Item {
  final int id;
  final String name;
  final String acquisition_date;
  final String quantity_with_unit;
  final String expiration_date;
  final int id;

  Item(
      {this.id,
      this.name,
      this.acquisition_date,
      this.expiration_date,
      this.quantity_with_unit,
      this.id});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  // Implement toString to make it easier to see information about
  // each item when using the print statement.
  @override
  String toString() {
    return 'Item{name: $name, '
        'quantity_with_unit: $quantity_with_unit, '
        'acquisition_date: $acquisition_date, '
        'expiration_date: $expiration_date)}';
  }
} //Inventory
