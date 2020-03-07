import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oauth2/oauth2.dart';

import '../models/item.dart';
import '../models/upc_base_response.dart';
import '../screens/home_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/login_screen.dart';
import '../utils/fade_route.dart';
import 'package:pantry/data/auth.dart' as auth;

bool offline = false;
var _client = new HttpClient()
  ..badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
var client = new IOClient(_client) as http.Client;

Future<String> register(loginData, BuildContext context) async {
  final grantEndpoint = Uri.parse(auth.url + "/o/token/");
  final registrationEndpoint = Uri.parse(auth.url + "/register/");
  var response;
  await Future<void>.delayed(Duration(seconds: 1));
  final username = '${(loginData.name)}';
  final password = '${(loginData.password)}';
  client = await oauth2.clientCredentialsGrant(
      grantEndpoint, auth.clientId, auth.clientSecret);
  response = await client.post(registrationEndpoint, headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "client_id": "${auth.clientId}",
    "client_secret": "${auth.clientSecret}",
    "username": '$username',
    "password": '$password'
  });
  if (response.statusCode == 201) {
    _alertRegister(context, "You have completed registration, please login.");
    return null;
  } else if (response.statusCode != null) {
    print("Not Registered, try again");
    _alertFailLogin(
        context, 'Failed to register to Pantry Application, Please log in');
    throw Exception('Failed to register to Pantry Application, Please log in');
  } else if (SocketException != null || TimeoutException != null) {
    _alertFailLogin(
        context,
        'Failed to register to Pantry Application, '
        'Please check your internet connection.');
  }
  return null;
} //register

var token;
Future<String> login(loginData, BuildContext context) async {
  // This URL is an endpoint that's provided by the authorization server. It's
  // usually included in the server's documentation of its OAuth2 API.
  final authorizationEndpoint = Uri.parse(auth.url + "/o/token/");

  // The user should supply their own username and password.
  final username = '${(loginData.name)}';
  final password = '${(loginData.password)}';
  var response;
  try {
    client = await oauth2.resourceOwnerPasswordGrant(
        authorizationEndpoint, username, password,
        identifier: auth.identifier, secret: auth.secret);
    token = await oauth2.resourceOwnerPasswordGrant(
        authorizationEndpoint, username, password,
        identifier: auth.identifier, secret: auth.secret);
    token = token.credentials.toString();
  } on AuthorizationException catch (e) {
    _alertFailLogin(
        context,
        'Failed to login to server. '
                'Please check your login information and ensure you are registered ' +
            e.toString());
  } on TimeoutException catch (e) {
    _alertFailLogin(context, 'Failed to login to server. ' + e.toString());
  } on SocketException catch (e) {
    _alertFailLogin(context, 'Failed to login to server. ' + e.toString());
  } on http.ClientException catch (e) {
    _alertFailLogin(context, 'Failed to login to server. ' + e.toString());
  } on Exception catch (e) {
    _alertFailLogin(context, 'Failed to login to server. ' + e.toString());
  }
  response = await client
      .get(auth.url + "/item")
      .timeout(Duration(milliseconds: 1000));
  if (response.statusCode == 200) {
    print(response.body);
    Navigator.of(context)
        .pushReplacement(FadePageRoute(builder: (context) => HomeScreen()));
    return null;
  } else if (response == null) {
    throw new Exception(
        'HTTP request failed, statusCode: ${response?.statusCode}');
  } else {
    print("Not Logged In to server");
    print(response.body);
    _alertFailLogin(context,
        'Failed to login to server. ' + response.statusCode.toString());
    throw Exception('Failed to load Inventory from Server');
  }
} //login

void logout(context) async {
  var response = await client.post(auth.url + "/o/revoke_token/", headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  }, body: {
    "token": token,
    "client_id": auth.identifier,
    "client_secret": auth.secret,
  });
  if (response.statusCode == 200) {
    print("token revoked");
  } else {
    print("token not revoked");
  }
  client.close();
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  _alertRegister(context, "You are logged off.  Please log in.");
}

Future<List<Item>> fetchInventory(BuildContext context) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String inventoryList = 'inventoryList';
  var response;
  if (offline) {
    response = sp.getString(inventoryList);
    return parseItems(response);
  } else {
    try {
      await Future<void>.delayed(Duration(seconds: 1));
      response = await client.get(auth.url + "/item", headers: {
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
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString(inventoryList, response.body);
      return parseItems(response.body);
    } else {
      // If that call was not successful, throw an error.
      _alertFail(context,
          'Could not connect to server ' + response.statusCode.toString());
      throw Exception('Failed to load pantry items');
    }
  }
}

Future<List<Item>> fetchSearch(
    BuildContext context, String searchString) async {
  var response;
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String inventoryList = 'inventoryList';
  if (offline) {
    response = sp.getString(inventoryList);
    return parseItemsOfflineSearch(response, searchString);
  } else {
    try {
      await Future<void>.delayed(Duration(seconds: 1));
      response =
          await client.get(auth.url + "/item?name=" + searchString, headers: {
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
      Connections.searchController.text = "";
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
} //parse items for fetchInventory

List<Item> parseItemsOfflineSearch(String responseBody, String searchString) {
  List<Item> items = new List<Item>();
  var parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<Item> parse = parsed.map<Item>((json) => Item.fromJson(json)).toList();
  for (var i = 0; i < parse.length; i++) {
    if (parse[i].name.toLowerCase().contains(searchString.toLowerCase())) {
      items.add(parse[i]);
    }
  }
  return items;
} //parse offline Search items

void delete(BuildContext context, int itemId) {
  if (offline) {
    _offlineAlert(context);
    return null;
  } else {
    _alertAreYouSure(context, itemId);
  }
} //delete called by view_item

Future<String> deleteItemForSure(context, itemId) async {
  var response;
  if (offline) {
    _offlineAlert(context);
    return null;
  } else {
    try {
      await Future<void>.delayed(Duration(seconds: 1));
      response = await client.delete(auth.url + "/item/$itemId/", headers: {
        "Content-Type": "application/json"
      }).timeout(Duration(seconds: 10));
      await Future<void>.delayed(Duration(seconds: 1));
    } on TimeoutException catch (e) {
      _alertFail(context, 'Failed to delete item. ' + e.toString());
    } on SocketException catch (e) {
      _alertFail(context, 'Failed to delete item. ' + e.toString());
    }
    if (response.statusCode == 200) {
      _alertSuccess(context, "Your Item was Deleted");
      return response.statusCode.toString();
    } else {
      // If that call was not successful, throw an error.
      _alertFail(context,
          'Could not connect to server ' + response.statusCode.toString());
      throw Exception('Failed to delete item');
    }
  }
} //delete item for sure!

void _alertAreYouSure(BuildContext context, int itemId) {
  new Alert(
    context: context,
    type: AlertType.warning,
    title: "Are You Sure?",
    desc: "This action cannot be undone!",
    buttons: [
      DialogButton(
        child: Text(
          "I Am Sure",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Colors.teal,
        onPressed: () => deleteItemForSure(context, itemId),
      ),
      DialogButton(
        child: Text(
          "Cancel",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ).show();
} //_offlineAlert

Future addToInventory(context, bool isUpdate, String itemID) async {
  String item;
  String message;
  if (isUpdate) {
    print(itemID);
    item = "{\"id\":\"$itemID\",";
    message = "Item successfully updated in Inventory";
  } else {
    item = "{";
    message = "Item successfully added to Inventory";
  }
  //try statement fo check for null items, show pop-up failure notices
  try {
    item += ("\"name\":\"${Connections.itemController.text}\",\"quantity_with_unit"
        "\":\"${Connections.unitController.text}\",\"acquisition_date\":\""
        "${Connections.acquisitionController.text.substring(0, 10)}\",\""
        "expiration_date\":\"${Connections.expirationController.text.substring(0, 10)}\"}");
    if ("${Connections.itemController.text}" == null) {
      throw new RangeError("Item name is null");
    } else if ("${Connections.itemController.text}" == "") {
      throw new RangeError("Item name cannot be empty!");
    }
    print(item);
    if (offline) {
      _offlineAlert(context);
    } else {
      final response = await client.post(auth.url + "/item",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: item);
      if (response.statusCode == 200) {
        _alertSuccess(context, message);
        Connections.itemController.clear();
        Connections.unitController.clear();
        Connections.expirationController.clear();
        Connections.acquisitionController.clear();
        return response;
      } else {
        throw Exception('Failed to load server Inventory');
      }
    }
  } on Error catch (e) {
    _alertEmpty(
        context,
        "Item Name and Dates must be filled. "
                "Please check your input and try again. " +
            e.toString());
  } on Exception catch (e) {
    _alertFail(context, e.toString());
  }
} //addToInventory - updates as well

Future<dynamic> fetchBarcodeInfo(http.Client client, String barcode) async {
  final response = await http
      .get('https://api.upcitemdb.com/prod/trial/lookup?upc=' + barcode);
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body);
    var baseResponse = BaseResponse.fromJson(responseBody);
    return baseResponse;
  } else {
    throw Exception('No information is available for this UPC.');
  }
} //fetchBarcodeInfo

class Checks {
  bool isUpdate;
  bool isSearch;

  Checks({this.isUpdate, this.isSearch});

  void setUpdate(bool isUpdate) {
    this.isUpdate = isUpdate;
  }

  void setSearch(bool isSearch) {
    this.isSearch = isSearch;
  }

  bool getUpdate() {
    return this.isUpdate;
  }

  bool getSearch() {
    return this.isSearch;
  }
}

void _alertSuccess(BuildContext context, String message) {
  new Alert(
    context: context,
    type: AlertType.info,
    title: "Success",
    desc: message,
    buttons: [
      DialogButton(
        child: Text(
          "Return",
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
    title: "Error",
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
    title: "Error",
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
  _offlineAlert(context);
}

void _offlineAlert(context) {
  new Alert(
    context: context,
    type: AlertType.warning,
    title: "Working Offline",
    desc: "While working offline you will not be able to modify, add or delete "
        "items from your pantry inventory.",
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
} //_offlineAlert

void _alertEmpty(context, String message) {
  new Alert(
    context: context,
    type: AlertType.error,
    title: "Error",
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
    title: "Success",
    desc: message,
    buttons: [
      DialogButton(
          child: Text(
            "Return",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.teal,
          onPressed: () => Navigator.pushReplacementNamed(context, "/")),
    ],
  ).show();
} //_alertSuccess

void alertRegisterDontUse(BuildContext context, String message) {
  new Alert(
    context: context,
    type: AlertType.info,
    title: "Success",
    desc: message,
    buttons: [
      DialogButton(
          child: Text(
            "Return",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          color: Colors.teal,
          onPressed: () => Navigator.pushReplacementNamed(context, "/")),
    ],
  ).show();
} //_alertSuccess
