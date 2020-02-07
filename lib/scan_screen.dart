import 'dart:convert';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'upc_base_response.dart';
import 'package:http/http.dart' as http;

class Scan extends StatefulWidget {
  @override
  ScanState createState() => new ScanState();
}

class ScanState extends State<Scan> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String barcode = '';
  http.Client client = new http.Client();
  BaseResponse baseResponse = BaseResponse();
  var formatter = new DateFormat('MM/dd/yyyy');

  /// Inputs
  var itemController = TextEditingController();
  var quantityController = TextEditingController();

  ///Used for JSON compatibility
  String acquisition;
  String expiration;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    itemController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    itemController.addListener(_itemController);
    quantityController.addListener(_quantityController);
  }

  _itemController() {
    print("${itemController.text}");
  }

  _quantityController() {
    print("${quantityController.text}");
  }

  Future<dynamic> fetchBarcodeInfo(http.Client client, String barcode) async {
    final response = await http
        .get('https://api.upcitemdb.com/prod/trial/lookup?upc=' + barcode);
    var responseBody = json.decode(response.body);
    setState(() => baseResponse = BaseResponse.fromJson(responseBody));
    print(baseResponse.items[0].title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Center(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              new Container(
                child: new RaisedButton(
                    onPressed: scan,
                    color: Colors.teal,
                    child: new Text("Scan")),
                padding: const EdgeInsets.all(8.0),
              ),
              new Text(barcode),
              pantryInfoInputsWidget(),
            ],
          ),
        )));
  }

  Widget pantryInfoInputsWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 4.0),
          child: TextField(
              controller: itemController,
              decoration: InputDecoration(
                labelText: 'Item',
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 4.0),
          child: TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: DateTimeField(
            format: formatter,
            decoration: InputDecoration(labelText: 'Acquisition Date'),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
            },
            onChanged: (dt) =>
                setState(() => acquisition = dt.toIso8601String()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: DateTimeField(
            format: formatter,
            decoration: InputDecoration(
              labelText: 'Expiration Date',
            ),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
            },
            onChanged: (dt) =>
                setState(() => expiration = dt.toIso8601String()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              return RaisedButton(
                onPressed: () => {}, //toJson goes between brackets
                color: Colors.teal,
                child: Text('Add Item'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget barcodeInfo() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: fetchBarcodeInfo(
              client, barcode), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            List<Widget> children;

            if (snapshot.hasData) {
              children = <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.teal,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Result: ${snapshot.data}'),
                )
              ];
            } else if (snapshot.hasError) {
              children = <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          },
        ),
      )
    ]);
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      String baseResponseBody = await fetchBarcodeInfo(client, barcode);
      if (baseResponseBody == null) {
        setState(() => itemController =
            TextEditingController(text: '${baseResponse.items[0].title}'));
        barcodeInfo();
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
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('barcode', barcode));
  }
}
