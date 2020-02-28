import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:pantry/models/item.dart';
//import 'home_screen.dart';
import 'package:pantry/data/connect_repository.dart';
import 'scan_screen.dart';

class Search extends StatefulWidget {

  @override
  SearchState createState() => new SearchState();

}

class SearchState extends State<Search> {

  final List<Item> foundItems = new List<Item>();
  BuildContext context;

  @override
  void dispose() {
    Connections.searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              pantrySearchWidget(context),
              new Container(
                child: new RaisedButton(
                    onPressed: () {print("searching...");
                      fetchSearch(context, "${Connections.searchController.text}");},
                      //fetchSearch(context, "chicken");},
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

  /*Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      baseResponse = await fetchBarcodeInfo(client, barcode);
      if (baseResponse != null) {
        setState(() => Connections.itemController =
            TextEditingController(text: '${baseResponse.items[0].title}'));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }*/
}
