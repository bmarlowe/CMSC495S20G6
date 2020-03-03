import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'search_screen.dart';
import 'scan_screen.dart';
import 'view_item.dart';
import 'package:pantry/data/connect_repository.dart';
import 'package:pantry/models/item.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final widgetOptions = [
    new PantryList(isSearch: false),
    new Search(),
    new Scan(isUpdate: false),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pantry Application',
            ),
          ],
        ),
        leading: Visibility(
          visible: true,
          child: Text(
            new DateFormat.yMMMEd('en_US').format(new DateTime.now()),
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.power),
            tooltip: 'Logout',
            enableFeedback: true,
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.local_library), title: Text('Inventory')),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text('Search')),
          BottomNavigationBarItem(
              icon: Icon(Icons.add), title: Text('Add Item')),
        ],
        currentIndex: selectedIndex,
        fixedColor: Colors.teal,
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}

class PantryList extends StatefulWidget {
  final bool isSearch;

  PantryList({Key key, @required this.isSearch}) : super(key: key);
  
  @override
  PantryListState createState() => PantryListState();
}

class PantryListState extends State<PantryList> {
  Future<Item> inventory;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isSearch) {
    return new Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<List<Item>>(
               future: fetchSearch(context, "${Connections.searchController.text}"),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return snapshot.hasData
                      ? InventoryList(inventory: snapshot.data, isSearch: true)
                      : Center(child: CircularProgressIndicator());
                }),
    );
    }
    else {
      return new Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<List<Item>>(
                future: fetchInventory(context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return snapshot.hasData
                      ? InventoryList(inventory: snapshot.data, isSearch: false)
                      : Center(child: CircularProgressIndicator());
                }));
    }
  }
}

class InventoryList extends StatelessWidget {
  final List<Item> inventory;
  final bool isSearch;

  InventoryList({Key key, Widget child, this.inventory, this.isSearch}) : super(key: key);

  Widget build(BuildContext context) {
    if (inventory.length == 0 && isSearch){
      return Align(
        alignment: Alignment.center,
        child: Text("No results found"),
      );
    } else {
    List<Item> invSorted = sortInventory(context, inventory);
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: invSorted.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        Color cardColor = colorCode(invSorted[index].expiration_date);
        return GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => new ViewItem(item: invSorted[index], color: cardColor),
                  ),
                );
              },
                child: Card(
                  margin: EdgeInsets.only(left: 5, right: 5, bottom: 20),
                  color: cardColor,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(invSorted[index].name.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                              ),
                          Text('Quantity: ' +
                              invSorted[index].quantity_with_unit.toString(),
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                          Text('Acquired: ' +
                              invSorted[index].acquisition_date.toString(),
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                          Text('Expiration: ' +
                              invSorted[index].expiration_date.toString(),
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)
                              ),
                        ])));
      },
    );
    }
  }

  Color colorCode(String expiration) {
    var todayRaw = new DateTime.now();
    DateTime today = new DateTime(todayRaw.year, todayRaw.month, todayRaw.day);

    String yearStr = expiration.substring(0, 4);
    String monthStr = expiration.substring(5, 7);
    String dayStr = expiration.substring(8, 10);
    int yearInt = int.parse(yearStr);
    int monthInt = int.parse(monthStr);
    int dayInt = int.parse(dayStr);
    DateTime itemExpire = new DateTime(yearInt, monthInt, dayInt);

    int check = itemExpire.compareTo(today);

    if (check <= 0) {
      return new Color(0xBBFF2222);
    }
    var difference = itemExpire.difference(today);

    if (difference.inDays <= 7) {
      return new Color(0xFFFFFF33);
    }
    return new Color(0xFF11BB33);
  }

  List<Item> sortInventory(BuildContext context, List<Item> inventory) {
    List<Item> sortedInventory = new List<Item>();
    List<Item> inv = inventory;


    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xBBFF2222)) {
        sortedInventory.add(inv[i]);
      }
    }

    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xFFFFFF33)) {
        sortedInventory.add(inv[i]);
      }
    }

    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xFF11BB33)) {
        sortedInventory.add(inv[i]);
      }
    }
    return sortedInventory;
  }
}
