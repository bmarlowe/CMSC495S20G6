import 'package:flutter/material.dart';

import 'package:pantry/models/item.dart';
import 'home_screen.dart';
import 'scan_screen.dart';


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
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 40),
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
        body: Center(
          child: PantryList(isSearch: true),
        )
    );
  
  }
}
