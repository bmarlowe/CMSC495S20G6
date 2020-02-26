import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/item.dart';
import '../models/upc_base_response.dart';
import '../screens/home_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/login_screen.dart';
import '../utils/fade_route.dart';
import 'local_save_file.dart';

bool offline = false;
var client = new http.Client();

//static String url = 'http://<YOUR IP>:8000/item'; //Testing real device
//static String url = 'http://localhost:8000/item'; //iOS TESTING
String url = 'http://10.0.2.2:8000/item'; //ANDROID TESTING
//static String url ='https://17dfcfcc-63d3-456a-a5d8-c5f394434f7c.mock.pstmn.io';

Future<String> register(loginData, BuildContext context) async {
  final registrationEndpoint = Uri.parse("http://10.0.2.2:8000/register/");
  var response;
  await Future<void>.delayed(Duration(seconds: 1));
  response = await http.post(registrationEndpoint, body: {
    "username": '${(loginData.name)}',
    "password": '${(loginData.password)}'
  });
  if (response.statusCode == 201) {
    _alertRegister(context, "You have completed registration, please login.");
    return null;
  } else {
    print("Not Registered, try again");
    _alertFailLogin(
        context, 'Failed to register to Pantry Application, Please log in');
    throw Exception('Failed to register to Pantry Application, Please log in');
  }
} //register

Future<String> login(loginData, BuildContext context) async {
  // This URL is an endpoint that's provided by the authorization server. It's
  // usually included in the server's documentation of its OAuth2 API.
  final authorizationEndpoint = Uri.parse("http://10.0.2.2:8000/o/token/");

  // The user should supply their own username and password.
  final username = '${(loginData.name)}';
  final password = '${(loginData.password)}';

  // The authorization server may issue each client a separate client
  // identifier and secret, which allows the server to tell which client
  // is accessing it. Some servers may also have an anonymous
  // identifier/secret pair that any client may use.
  //
  // Some servers don't require the client to authenticate itself, in which case
  // these should be omitted.
  final identifier = "swMGjzCf9s92ji4LHaFeDtTKS93L3py2zOcM3BkJ";
  final secret =
      "gXWHX7R3qzOU4ykaf9oUb2uuqoijVnEYmI9AobXjzXUHt862qtawTv6bdqxrAhNrmgUFeVptOXe981uho2qUuEw7i2fIliH5dsQjsjrqcrobes7FLMaWWsWXzvFHdezt";

  // Make a request to the authorization endpoint that will produce the fully
  // authenticated Client.
  client = await oauth2.resourceOwnerPasswordGrant(
      authorizationEndpoint, username, password,
      identifier: identifier, secret: secret);

  // Once you have the client, you can use it just like any other HTTP client.
  var response;

  try {
    await Future<void>.delayed(Duration(seconds: 1));
    response = await client.get(url).timeout(Duration(seconds: 10));
  } on oauth2.AuthorizationException catch (e) {
    _alertFailLogin(
        context,
        'Failed to login to server. '
                'Please check your login information and ensure you are registered ' +
            e.toString());
  } on TimeoutException catch (e) {
    _alertFailLogin(context, 'Failed to login to server. ' + e.toString());
  }
  if (response.statusCode == 200) {
    print(response.toString());
    Navigator.of(context)
        .pushReplacement(FadePageRoute(builder: (context) => HomeScreen()));
    return null;
  } else {
    print("Not Logged In to server");
    print(response.body);
    _alertFailLogin(context,
        'Failed to login to server. ' + response.statusCode.toString());
    throw Exception('Failed to load to Server Inventory');
  }
} //login

logout(context) {
  client.close();
  Navigator.pushReplacementNamed(context, "/");
}

Future<List<Item>> fetchInventory(BuildContext context) async {
  var response;
  if (offline) {
    //TODO make offline persistent data work
    return null;
  } else {
    try {
      await Future<void>.delayed(Duration(seconds: 1));
      response = await client.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      }).timeout(const Duration(seconds: 10));
      await Future<void>.delayed(Duration(seconds: 1));
    } on TimeoutException catch (e) {
      _alertFail(context, 'Failed to load server pantry. ' + e.toString());
    } on SocketException catch (e) {
      _alertFail(context, 'Failed to load server pantry. ' + e.toString());
    }
    if (response.statusCode == 200) {
      return parseItems(response.body);
    } else {
      // If that call was not successful, throw an error.
      _alertFail(context,
          'Did not connect to server ' + response.statusCode.toString());
      throw Exception('Failed to load pantry items');
    }
  }
}

List<Item> parseItems(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Item>((json) => Item.fromJson(json)).toList();
}

Future addToInventory(context) async {
  Item item;
  //try statement fo check for null items, show pop-up failure notices
  try {
    item = new Item(
      name: "${Connections.itemController.text}",
      quantity_with_unit: "${Connections.unitController.text}",
      acquisition_date:
          "${Connections.acquisitionController.text.substring(0, 10)}",
      expiration_date:
          "${Connections.expirationController.text.substring(0, 10)}",
    );
    if ("${Connections.itemController.text}" == null) {
      throw new RangeError("item name is null");
    }
  } on RangeError {
    _alertEmpty(
        context,
        "Item Name and Dates must be filled., "
        "Please check your input and try again");
  }
  var responseBody = json.encode(item);
  print(responseBody);

  if (offline) {
    //TODO make offline persistent data work
  } else {
    final response = await client.post(url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: responseBody);
    if (response.statusCode == 200) {
      _alertSuccess(context, 'Item sucessfully added to inventory');
      return response;
    } else {
      writeItem(responseBody);
      print(response.body);
      print(responseBody);
      print(response.statusCode);
      print(response.toString());
      _alertFail(context, 'Item not added to server');
      throw Exception('Failed to load to server Inventory');
    }
  }
} //addToInventory

Future<dynamic> fetchBarcodeInfo(http.Client client, String barcode) async {
  final response = await http
      .get('https://api.upcitemdb.com/prod/trial/lookup?upc=' + barcode);
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body);
    var baseResponse = BaseResponse.fromJson(responseBody);
    return baseResponse;
  } else {
    throw Exception('Failed to load item from website');
  }
} //fetchBarcodeInfo

void _alertSuccess(BuildContext context, String message) {
  new Alert(
    context: context,
    type: AlertType.info,
    title: "CONGRATS",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "Transfer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Colors.teal,
        onPressed: () => Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => HomeScreen(),
        )),
      ),
    ],
  ).show();
} //_alertSuccess

void _alertFail(BuildContext context, String message) {
  new Alert(
    context: context,
    type: AlertType.error,
    title: "ERROR",
    desc: message,
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
} //_alertFail

void _alertFailLogin(context, String message) {
  new Alert(
    context: context,
    type: AlertType.error,
    title: "ERROR",
    desc: message,
    buttons: [
      DialogButton(
          child: Text(
            "Try Again",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.teal,
          onPressed: () => Navigator.of(context).pushReplacement(
              FadePageRoute(builder: (BuildContext context) => LoginScreen()))),
      DialogButton(
        child: Text(
          "Work Offline",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => _workOffline(context),
      ),
    ],
  ).show();
} //_alertFailLogin

void _workOffline(context) {
  offline = true;
  Navigator.of(context).pushReplacement(
      FadePageRoute(builder: (BuildContext context) => HomeScreen()));
}

void _alertEmpty(context, String message) {
  new Alert(
    context: context,
    type: AlertType.error,
    title: "OOPS!",
    desc: message,
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
} //_alertEmpty

void _alertRegister(BuildContext context, String message) {
  new Alert(
    context: context,
    type: AlertType.info,
    title: "CONGRATS",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "Transfer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Colors.teal,
        onPressed: () => Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => LoginScreen(),
        )),
      ),
    ],
  ).show();
} //_alertSuccess
