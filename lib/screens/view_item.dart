import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pantry/data/connect_repository.dart';
import 'scan_screen.dart';
import 'package:pantry/data/globals.dart' as globals;

class ViewItem extends StatelessWidget {

  ViewItem({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("view_item card:");
    print(globals.currentItem.name);
    return new Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Pantry Application',
            ),
            Visibility(
              visible: true,
              child: Text(
                new DateFormat.yMMMMd('en_US').format(new DateTime.now()),
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Delete Item:", style: TextStyle(fontSize: 12.0)),
              new IconButton(
                icon: Icon(Icons.highlight_off),
                iconSize: 20,
                enableFeedback: true,
                onPressed: () => delete(context, globals.currentItem.id),
              ),
            ]
          ),
        ],
      ),
      body: Container(
        color: globals.color,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(globals.currentItem.name.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                ),
              Text('Quantity: ' +
                globals.currentItem.quantity_with_unit.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Text('Acquired: ' +
                globals.currentItem.acquisition_date.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Text('Expiration: ' +
                globals.currentItem.expiration_date.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Builder(
                builder: (context) {
                return RaisedButton(
                  onPressed: () {
                    //Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) { print(globals.currentItem.id.toString() + " " + globals.currentItem.toString());
                          globals.isUpdate = true;
                          return new Scan();
                          }
                        ),
                      );
                  },
                  color: Colors.teal,
                  child: Text('Modify Item'),
                );
                },
              )
            ]
          )
        )
      )
    );

  }
}
