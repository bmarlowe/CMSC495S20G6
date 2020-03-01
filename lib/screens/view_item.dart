import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:pantry/models/item.dart';


class ViewItem extends StatelessWidget {

  final Item item;
  final Color color;

  ViewItem({Key key, @required this.item, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                onPressed: () => {print("delete item")},
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
            ]
          )
        )
      )
    );
  }
}