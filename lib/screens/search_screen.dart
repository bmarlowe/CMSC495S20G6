import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:pantry/models/item.dart';
import 'home_screen.dart';
import 'package:pantry/data/connect_repository.dart';
import 'scan_screen.dart';
import 'view_item.dart';

class Search extends StatefulWidget {

  @override
  SearchState createState() => new SearchState();

}

class SearchState extends State<Search> {
  final List<Item> foundItems = new List<Item>();
  BuildContext context;

  @override
  void initState() {
    super.initState();
    Connections.searchController.addListener(_searchController);
  }

  _searchController() {
    print("${Connections.searchController.text}");
  }
  
  @override
  Widget build(context) {
    return new Scaffold(
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              pantrySearchWidget(context),
              new Container(
                child: new RaisedButton(
                    onPressed: () {print("searching...");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchDisplay(),
                        ),
                      );
                    },
                    color: Colors.teal,
                    child: new Text("Search")),
                padding: const EdgeInsets.all(8.0),
              ),
            ],
          ),
        )));
  }

  Widget pantrySearchWidget(context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 4.0),
          child: TextField(
              controller: Connections.searchController,
              decoration: InputDecoration(
                labelText: 'Item name:',
              )),
        ),
      ],
    );
  }

}

class SearchDisplay extends StatefulWidget {

  @override
  SearchDisplayState createState() => SearchDisplayState();

}

class SearchDisplayState extends State<SearchDisplay> {
  Future<Item> inventory;
  var isLoading = false;

  @override
  Widget build(context){
    return new Scaffold(
      appBar: AppBar(
        leading:
        new IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Return to Search',
            enableFeedback: true,
            onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      ? SearchResults(inventory: snapshot.data)
                      : Center(child: CircularProgressIndicator());
                }));
  
  }
}

  class SearchResults extends StatelessWidget {
    final List<Item> inventory;

    SearchResults({this.inventory});
  
  @override
  Widget build(context) {
    Connections.searchController.text = "";
    if (inventory.length == 0){
      return Text("No results found");
    } else {
    return GridView.builder(
      itemCount: inventory.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        return GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewItem(item: inventory[index], color: Colors.teal),
                  ),
                );
              },
                child: Card(
                  color: Colors.teal,
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Column(
                        children: [
                          Text(inventory[index].name.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Quantity: ' +
                              inventory[index].quantity_with_unit.toString()),
                          Text('Acquisition: ' +
                              inventory[index].acquisition_date.toString()),
                          Text('Expiration: ' +
                              inventory[index].expiration_date.toString()),
                          Container()
                        ]))));
      },
    );
    }
  }
}
