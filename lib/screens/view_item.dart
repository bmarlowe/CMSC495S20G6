import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pantry/data/connect_repository.dart';
import 'package:pantry/models/item.dart';


class ViewItem extends StatelessWidget {

  final Item item;

  ViewItem({Key key, @required this.item}) : super(key: key);

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
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.highlight_off),
            enableFeedback: true,
            onPressed: () => {print("delete item")},
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(item.name.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Quantity: ' +
              item.quantity_with_unit.toString()),
            Text('Acquisition: ' +
              item.acquisition_date.toString()),
            Text('Expiration: ' +
              item.expiration_date.toString()),
          ]
        )
      )
    );
  }
}