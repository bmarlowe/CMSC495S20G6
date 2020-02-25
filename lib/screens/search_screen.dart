import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantry/models/item.dart';
import 'home_screen.dart';

class Search extends StatelessWidget {
final List<Item> foundItems;

  Search({Key key, this.foundItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final inventory = InventoryList.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Search...',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            enableFeedback: true,
            onPressed: () {
              showSearch(
                context: context,
                //delegate: PantrySearchDelegate(inventory),
              );
            },
          ),
        ],
      )
    );
  }

}
//TODO - Need a way for the search delegate to see the InventoryList inventory.
class PantrySearchDelegate extends SearchDelegate<String> {
  final InventoryList inventory;
  List<Item> foundItems;

  PantrySearchDelegate(this.inventory);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    for (var i=0; i<inventory.inventory.length; i++) {
      if (inventory.inventory[i].name.toLowerCase() == "chicken") {
        this.foundItems.add(inventory.inventory[i]);
        print("item found!");
      }
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
