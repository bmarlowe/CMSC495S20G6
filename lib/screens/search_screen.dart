import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantry/models/item.dart';
import 'home_screen.dart';

class Search extends StatefulWidget {
  @override
  SearchState createState() => new SearchState();
}

class SearchState extends State<Search> {
  var formatter = new DateFormat('yyyy-MM-dd');
  BuildContext context;
  List<Item> inventory;

  get scaffoldKey => null;

  @override
  Widget build(context) {
    return Scaffold(
        key: scaffoldKey,
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              new Container(
                child: Text("Search"),
              ),
            ],
          ),
        )));
  }

  void search() {
    print("searching...");
  }
}