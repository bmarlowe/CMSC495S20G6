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
    new PantryList(),
    new Search(),
    new Scan(),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //key: scaffoldKey,
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
          /*new IconButton(
            icon: Icon(Icons.search),
            enableFeedback: true,
            onPressed: () => print("searching..."),
          ),*/
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
  PantryList({Key key}) : super(key: key);
  @override
  PantryListState createState() => PantryListState();
}

class PantryListState extends State<PantryList> {
  Future<Item> inventory;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                      ? InventoryList(inventory: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                }));
  }
}

class InventoryList extends StatelessWidget {
  final List<Item> inventory;

  InventoryList({Key key, Widget child, this.inventory}) : super(key: key);

  Widget build(BuildContext context) {
    List<Item> invSorted = sortInventory(context, inventory);
    //searchByName(context, invSorted);
    return GridView.builder(
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
                  builder: (context) => ViewItem(item: invSorted[index]),
                ),
              );
            },
            child: Card(
                color: cardColor,
                child: SizedBox(
                    width: 200,
                    height: 100,
                    //margin: new EdgeInsets.all(1),
                    child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(invSorted[index].name.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Quantity: ' +
                              invSorted[index].quantity_with_unit.toString()),
                          Text('Acquisition: ' +
                              invSorted[index].acquisition_date.toString()),
                          Text('Expiration: ' +
                              invSorted[index].expiration_date.toString()),
                          Container(
                              /*child: LayoutBuilder(
                              builder: (context, constraints) {
                                WidgetsBinding.instance.addPostFrameCallback((_) => _insertSearch(context));
                                WidgetsBinding.instance.addPostFrameCallback((_) => _showSearchField(context));
                                return Container();
                              }
                            )*/
                              )
                        ]))));
      },
    );
  }

  Color colorCode(String expiration) {
    var todayRaw = new DateTime.now();
    DateTime today = new DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    //print(today);
    String yearStr = expiration.substring(0, 4);
    String monthStr = expiration.substring(5, 7);
    String dayStr = expiration.substring(8, 10);
    int yearInt = int.parse(yearStr);
    int monthInt = int.parse(monthStr);
    int dayInt = int.parse(dayStr);
    DateTime itemExpire = new DateTime(yearInt, monthInt, dayInt);
    //print(itemExpire);
    int check = itemExpire.compareTo(today);
    //print(check);
    if (check <= 0) {
      return new Color(0xFFFF2222);
    }
    var difference = itemExpire.difference(today);
    //print(difference.inDays);
    if (difference.inDays <= 7) {
      return new Color(0xFFFFFF33);
    }
    return new Color(0xFF11BB33);
  }

  List<Item> sortInventory(BuildContext context, List<Item> inventory) {
    List<Item> sortedInventory = new List<Item>();
    List<Item> inv = inventory;
    //List<int> expirationOrder;
    bool allRed = false;
    bool allYellow = false;
    bool allGreen = false;
    //TODO - This is very ugly, needs rewritten
    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xFFFF2222)) {
        sortedInventory.add(inv[i]);
      }
    }
    allRed = true;
    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xFFFFFF33)) {
        sortedInventory.add(inv[i]);
      }
    }
    allYellow = true;
    for (var i = 0; i < inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration_date);
      if (colorCheck == Color(0xFF11BB33)) {
        sortedInventory.add(inv[i]);
      }
    }
    allGreen = true;
    return sortedInventory;
  }

  List<Item> searchByName(
      BuildContext context, List<Item> inventory, String query) {
    List<Item> foundItems;
    print(query);
    for (var i = 0; i < inventory.length; i++) {
      print(inventory[i].name);
    }
    return foundItems;
  }
}
