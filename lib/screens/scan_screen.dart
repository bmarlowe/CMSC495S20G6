import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pantry/models/item.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../data/connect_repository.dart';
import '../models/upc_base_response.dart';
import 'package:pantry/data/globals.dart' as globals;

class Connections {
  /// Inputs
  static var itemController = TextEditingController();
  static var unitController = TextEditingController();
  static var expirationController = TextEditingController();
  static var acquisitionController = TextEditingController();
  static var searchController = TextEditingController();
}

class Scan extends StatefulWidget {
  Scan({Key key}) : super(key: key);

  @override
  ScanState createState() => new ScanState();
}

class ScanState extends State<Scan> {
  String barcode = '';
  http.Client client = new http.Client();
  BaseResponse baseResponse = new BaseResponse();
  var formatter = new DateFormat('yyyy-MM-dd');
  BuildContext context;
  String itemID = "";

  @override
  void initState() {
    super.initState();
    Connections.itemController.addListener(_itemController);
    Connections.unitController.addListener(_unitController);
    Connections.expirationController.addListener(_acquisitionController);
    Connections.acquisitionController.addListener(_expirationController);
  }

  _itemController() {
    print("${Connections.itemController.text}");
  }

  _unitController() {
    print("${Connections.unitController.text}");
  }

  _acquisitionController() {
    print("${Connections.acquisitionController.text}");
  }

  _expirationController() {
    print("${Connections.expirationController.text}");
  }

  String ifUpdate(Item item) {
    print("updating...");
    print(item.id.toString() + " " + item.toString());
    String itemID = item.id.toString();
    Connections.itemController.text = item.name;
    Connections.unitController.text = item.quantity_with_unit;
    Connections.acquisitionController.text = item.acquisition_date;
    Connections.expirationController.text = item.expiration_date;
    return itemID;
  }

  void clear() {
    Connections.itemController.clear();
    Connections.unitController.clear();
    Connections.expirationController.clear();
    Connections.acquisitionController.clear();
  }

  void _alertUpdateClear(BuildContext context) {
    new Alert(
      context: context,
      type: AlertType.error,
      title: "Error",
      desc: "Cannot clear during update",
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

  Widget build(context) {
    if (globals.isUpdate) {
      itemID = ifUpdate(globals.currentItem);
      return new WillPopScope(
          onWillPop: () async => false,
          child: new Scaffold(
            appBar: AppBar(
              leading: Container(),
              title: Center(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pantry Application',
                    ),
                    Visibility(
                      visible: true,
                      child: Text(
                        new DateFormat.yMMMMd('en_US')
                            .format(new DateTime.now()),
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                pantryInput(context, true, globals.currentItem),
                new RaisedButton(
                    onPressed: () {
                      globals.isUpdate = false;
                      clear();
                      Navigator.pop(context);
                    },
                    color: Colors.teal,
                    child: new Text("Back")),
              ],
            )),
          ));
    } else {
      Item item = new Item();
      return new Scaffold(
        body: Center(
          child: pantryInput(context, false, item),
        ),
      );
    }
  }

  Widget barcodeInput(context) {
    return Center(
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          new Container(
            child: new RaisedButton(
                onPressed: scan,
                color: Colors.teal[100],
                child: new Text("Scan Barcode")),
            padding: const EdgeInsets.all(8.0),
          ),
          new Text((() {
            if (barcode != null) {
              return barcode;
            }
            return '';
          })()),
        ],
      ),
    ));
  }

  Widget pantryInput(context, bool isUpdate, Item item) {
    Widget child;
    if (isUpdate) {
      child = Container();
    } else {
      child = barcodeInput(context);
    }
    return Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 4.0),
                  child: TextField(
                      controller: Connections.itemController,
                      decoration: InputDecoration(
                        labelText: 'Item: What is it?',
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 4.0),
                  child: TextField(
                      controller: Connections.unitController,
                      decoration: InputDecoration(
                        labelText: "Unit: How much?",
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: DateTimeField(
                    format: formatter,
                    controller: Connections.acquisitionController,
                    decoration: InputDecoration(labelText: 'Acquisition Date'),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 40),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 40));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: DateTimeField(
                    format: formatter,
                    controller: Connections.expirationController,
                    decoration: InputDecoration(
                      labelText: 'Expiration Date',
                    ),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 40),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 40));
                    },
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                              onPressed: () {
                                print(isUpdate);
                                if (isUpdate) {
                                  _alertUpdateClear(context);
                                } else {
                                  clear();
                                }
                              },
                              color: Colors.teal,
                              child: Text('Clear All'),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                              onPressed: () {
                                print(isUpdate);
                                if (isUpdate) {
                                  ifUpdate(globals.currentItem);
                                } else {
                                  clear();
                                }
                              },
                              color: Colors.teal,
                              child: Text('Reset'),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                              onPressed: () {
                                print(isUpdate);
                                print(itemID);
                                addToInventory(context, isUpdate, itemID);
                                globals.isUpdate = false;
                                print(globals.isUpdate);
                                //Navigator.pop(context);
                              },
                              color: Colors.teal,
                              child: Text('Add Item'),
                            );
                          },
                        ),
                      ),
                    ]),
                child,
              ],
            )));
  }

  Future scan() async {
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
          this.barcode = '';
          print("Camera has not been granted permission");
        });
      } else {
        setState(() => this.barcode = '');
        print("Unknown error: $e");
      }
    } on FormatException {
      setState(() => this.barcode = '');
      print("null: User used the back arrow to return before scanning.");
    } catch (e) {
      setState(() => this.barcode = '');
      print("Unknown error: $e");
    }
    if (!mounted) return;
  }

  Widget datePicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: DateTimeField(
        format: formatter,
        controller: Connections.acquisitionController,
        decoration: InputDecoration(labelText: 'Acquisition Date'),
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 40),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(DateTime.now().year + 40));
        },
        onChanged: (dt) => setState(() {
          Connections.acquisitionController.text;
        }),
      ),
    );
  }
}
