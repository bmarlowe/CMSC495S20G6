import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
part 'item.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Item {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String acquisition_date;
  @HiveField(2)
  final String quantity_with_unit;
  @HiveField(3)
  final String expiration_date;

  Item(
      {this.name,
      this.acquisition_date,
      this.expiration_date,
      this.quantity_with_unit});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  // Convert a Item into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'acquisition_date': acquisition_date,
      'expiration_date': expiration_date,
      'quantity_with_unit': quantity_with_unit,
    };
  }

  // Implement toString to make it easier to see information about
  // each item when using the print statement.
  @override
  String toString() {
    return 'Item{name: $name, '
        'quantity_with_unit: $quantity_with_unit '
        'acquisition_date: $acquisition_date, '
        'expiration_date: $expiration_date)}';
  }
} //Inventory
