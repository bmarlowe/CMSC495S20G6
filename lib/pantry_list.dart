import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:pantry/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
part 'pantry_list.g.dart';

//TODO - Change url to correct url for post/get.
//String url = 'http://localhost:8000/item'; //iOS TESTING
String url = 'http://10.0.2.2:8000/item'; //ANDROID TESTING
//String url = 'https://17dfcfcc-63d3-456a-a5d8-c5f394434f7c.mock.pstmn.io';

Future<List<Inventory>> fetchInventory(
    http.Client client, BuildContext context) async {
  final response = await http.get(url, headers: {
    "Content-Type": "application/json",
    //"Accept": "application/json",
    "Authorization": GlobalData.auth,
  }); //response

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return compute(parseItems, response.body);
  } else {
    // If that call was not successful, throw an error.
    _alertFail(context);
    throw Exception('Failed to load pantry items');
  }
}

List<Inventory> parseItems(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Inventory>((json) => Inventory.fromJson(json)).toList();
}

@JsonSerializable()
class Inventory {
  final String name;
  final String acquisition;
  //final int quantity;
  //final String unit;
  final String expiration;

  Inventory(
      {this.name,
      this.acquisition,
      //this.unit,
      //this.quantity,
      this.expiration});

  factory Inventory.fromJson(Map<String, dynamic> json) =>
      _$InventoryFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryToJson(this);
} //Inventory

class PantryList extends StatefulWidget {
  PantryList({Key key}) : super(key: key);
  @override
  PantryListState createState() => PantryListState();
}

class PantryListState extends State<PantryList> {
  Future<Inventory> inventory;
  var isLoading = false;
  //List<GridTile> _inventory = <GridTile>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<List<Inventory>>(
                future: fetchInventory(http.Client(), context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return snapshot.hasData
                      ? InventoryList(inventory: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                }
              )
      );
  }

}

class InventoryList extends StatelessWidget {
  final List<Inventory> inventory;

  InventoryList({Key key, this.inventory}) : super(key: key);
  
  Widget build(BuildContext context) {
    List<Inventory> invSorted = sortInventory(context, inventory);
    return GridView.builder(
      itemCount: invSorted.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        Color cardColor = colorCode(invSorted[index].expiration);
        return Card(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              //Text('Quantity: ' + inventory[index].quantity.toString()),
              Text('Acquisition: ' + invSorted[index].acquisition.toString()),
              Text('Expiration: ' + invSorted[index].expiration.toString()),
            ]
          )
        )
      );
        
      },
    );
  }

  Color colorCode(String expiration) {
    var todayRaw = new DateTime.now();
    DateTime today = new DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    //print(today);
    String yearStr = expiration.substring(0,4);
    String monthStr = expiration.substring(5,7);
    String dayStr = expiration.substring(8,10);
    int yearInt = int.parse(yearStr);
    int monthInt = int.parse(monthStr);
    int dayInt = int.parse(dayStr);
    DateTime itemExpire = new DateTime(yearInt, monthInt, dayInt);
    //print(itemExpire);
    int check = itemExpire.compareTo(today);
    //print(check);
    if(check <= 0) {
      return new Color(0xFFFF2222);
    }
    var difference = itemExpire.difference(today);
    //print(difference.inDays);
    if(difference.inDays <= 7) {
      return new Color(0xFFFFFF33);
    }
    return new Color(0xFF11BB33);
  }

  List<Inventory> sortInventory(BuildContext context, List<Inventory> inventory) {
    List<Inventory> sortedInventory = new List<Inventory>();
    List<Inventory> inv = inventory;
    //List<int> expirationOrder;
    bool allRed = false;
    bool allYellow = false;
    bool allGreen = false;
    //TODO - This is very ugly, needs rewritten
    for(var i=0; i<inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration);
      if (colorCheck == Color(0xFFFF2222)) {
        sortedInventory.add(inv[i]);
      }
    }
    allRed = true;
    for(var i=0; i<inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration);
      if (colorCheck == Color(0xFFFFFF33)) {
        sortedInventory.add(inv[i]);
      }
    }
    allYellow = true;
    for(var i=0; i<inv.length; i++) {
      Color colorCheck = colorCode(inv[i].expiration);
      if (colorCheck == Color(0xFF11BB33)) {
        sortedInventory.add(inv[i]);
      }
    }
    allGreen = true;
    return sortedInventory;
  }

}

void _alertFail(context) {
  new Alert(
    context: context,
    type: AlertType.error,
    title: "ERROR",
    desc: "Pantry Failed to Load.",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Colors.teal,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ).show();
}

/**
 *  in pubspec.yaml:
    dependencies:
    flutter:
    sdk: flutter
    http: ^0.12.0
    json_annotation: ^2.0.0
    dev_dependencies:
    flutter_test:
    sdk: flutter
    build_runner: ^1.0.0
    json_serializable: ^2.0.0
 */
