import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';

class ItemDatabase {
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  Future initDB() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "item.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute("Create TABLE Item ("
          "name TEXT,"
          "acquisition_date TEXT,"
          "expiration_date' TEXT,"
          "quantity_with_unit TEXT)");
    });
  } //initDB

  // Define a function that inserts items into the database
  Future<void> insertItem(Item item) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the item into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same item is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'item',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the items from the items table.
  Future<List<Item>> getAllItems() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Items.
    final List<Map<String, dynamic>> maps = await db.query('item');

    // Convert the List<Map<String, dynamic> into a List<Item>.
    return List.generate(maps.length, (i) {
      return Item(
        name: maps[i]['name'],
        quantity_with_unit: maps[i]['quantity_with_unit'],
        acquisition_date: maps[i]['acquisition'],
        expiration_date: maps[i]['expiration'],
      );
    });
  }

  //A method that updates an item in the database
  Future<void> updateItem(Item item) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given item.
    await db.update(
      'item',
      item.toMap(),
      // Ensure that the Item has a matching id.
      where: "name = ?",
      // Pass the Item's id as a whereArg to prevent SQL injection.
      whereArgs: [item.name],
    );
  }

  //A method that deletes an item in the database
  Future<void> deleteItem(String name) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Item from the Database.
    await db.delete(
      'item',
      // Use a `where` clause to delete a specific item.
      where: "name = ?",
      // Pass the item's name as a whereArg to prevent SQL injection.
      whereArgs: [name],
    );
  }

  //A method to delete everything from the database
  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Item");
  }
}
