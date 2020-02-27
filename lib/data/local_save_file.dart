import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../screens/scan_screen.dart';
import '../utils/fade_route.dart';

File jsonFile;
Directory dir;
String server = "server_inventory.json";
bool fileExists = false;

Future getDirectory() async {
  /*to store files temporary we use getTemporaryDirectory() but we want
    permanent storage so we use getApplicationDocumentsDirectory() */
  String dir = (await getApplicationSupportDirectory()).path;
  print("Directory from getDirectory" + dir);
  jsonFile = new File(dir + "/" + server);
  fileExists = jsonFile.existsSync();
}

void existingFile(context) async {
  await getDirectory();
  if (fileExists) {
    print("File exists");
  } else {
    print("File does not exist!");
    createFile(context, dir);
  }
}

Future<String> readLocalInventoryFile(context) async {
  existingFile(context);
  try {
    String dir = (await getApplicationSupportDirectory()).path;
    Future<String> body = File(dir + "/" + server).readAsString();
    return body;
  } catch (e) {
    print(e.toString());
    return e.toString();
  }
} //readLocalInventoryFile

Future<void> writeItem(response, context) async {
  try {
    String dir = (await getApplicationSupportDirectory()).path;
    File(dir + "/" + server).writeAsStringSync(response, mode: FileMode.append);
    print("write item try statement: " + dir + "/" + server);
    return null;
  } catch (e) {
    print(e.toString());
    return e.toString();
  }
} //writeItem

Future<void> writeInventoryFromServer(response, context) async {
  existingFile(context);
  try {
    String dir = (await getApplicationSupportDirectory()).path;
    print("Directory from writeInventoryFromServer: " + dir);
    print(response);
    File(dir + "/" + server).writeAsStringSync(response);
  } catch (e) {
    print(e.toString());
  }
} //writeInventoryFromServer

void createFile(context, Directory dir) {
  print("Creating file!");
  File file = new File(dir.toString() + "/" + server);
  _alertCreatingFile(context);
  file.createSync();
  fileExists = true;
}

void _alertCreatingFile(context) {
  new Alert(
    context: context,
    type: AlertType.info,
    title: "Creating file on your phone.",
    desc: "Please transfer to add an item to begin.",
    buttons: [
      DialogButton(
        child: Text(
          "Transfer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        color: Colors.teal,
        onPressed: () => Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => Scan(),
        )),
      ),
    ],
  ).show();
} //_alertSuccess
