import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pantry/data/connect_repository.dart';

import 'package:pantry/models/item.dart';

import 'scan_screen.dart';

class ViewItem extends StatefulWidget {
  final Item item;
  final Color color;

  ViewItem({Key key, @required this.item, @required this.color}) : super(key: key);

  @override
  ViewItemState createState() => new ViewItemState();

}

class ViewItemState extends State<ViewItem> {
  Item item;
  Color color;

  @override
  Widget build(BuildContext context) {
    item = widget.item;
    color = widget.color;
    print(item.name);
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
                onPressed: () => delete(context, item.id),
              ),
            ]
          ),
        ],
      ),
      body: Container(
        color: color,
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(item.name.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
                ),
              Text('Quantity: ' +
                item.quantity_with_unit.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Text('Acquired: ' +
                item.acquisition_date.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Text('Expiration: ' +
                item.expiration_date.toString(),
                style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold)
                ),
              Builder(
                builder: (context) {
                return RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) { print(item.id.toString() + " " + item.toString());
                          return new Scan(isUpdate: true, item: item);
                          }
                        ),
                      );
                    //Scan(isUpdate: true, item: item);
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
