import 'dart:async';

import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../data/connect_repository.dart';
import '../models/upc_base_response.dart';

class Connections {
  /// Inputs
  static var itemController = TextEditingController();
  static var unitController = TextEditingController();
  static var expirationController = TextEditingController();
  static var acquisitionController = TextEditingController();
  static var searchController = TextEditingController();
}

class Scan extends StatefulWidget {
  @override
  ScanState createState() => new ScanState();
}

class ScanState extends State<Scan> {
  String barcode = '';
  http.Client client = new http.Client();
  BaseResponse baseResponse = new BaseResponse();
  var formatter = new DateFormat('yyyy-MM-dd');
  BuildContext context;

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

  @override
  Widget build(context) {
    return new Scaffold(
        //key: scaffoldKey,
        body: Center(
            child: SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          new Container(
            child: new RaisedButton(
                onPressed: scan,
                color: Colors.teal[50],
                child: new Text("Scan Barcode")),
            padding: const EdgeInsets.all(8.0),
          ),
          new Text((() {
            if (barcode != null) {
              return barcode;
            }
            return '';
          })()),
          pantryInfoInputsWidget(context),
        ],
      ),
    )));
  }

  Widget pantryInfoInputsWidget(context) {
    return Column(
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
            onChanged: (dt) =>
                setState(() => Connections.acquisitionController.text),
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
            onChanged: (dt) =>
                setState(() => Connections.expirationController.text),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              return RaisedButton(
                onPressed: () => addToInventory(context),
                color: Colors.teal,
                child: Text('Add Item'),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              return RaisedButton(
                onPressed: () => clear(),
                color: Colors.teal,
                child: Text('Clear All Text'),
              );
            },
          ),
        ),
      ],
    );
  }

  void clear(){
    Connections.itemController.clear();
    Connections.unitController.clear();
    Connections.expirationController.clear();
    Connections.acquisitionController.clear();
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
  }
}
