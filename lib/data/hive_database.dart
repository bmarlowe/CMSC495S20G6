import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/item.dart';

Future<Box> createDatabase() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(ItemAdapter());
  final itemBox = await Hive.openBox('item');
  return itemBox;
}
