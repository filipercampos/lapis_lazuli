import 'dart:convert';

import 'package:flutter/material.dart';

class JsonUtil{

  Future<Map> readJson(String path, BuildContext context) async {
    var jsonData = await DefaultAssetBundle.of(context).loadString(path);
    final map = json.decode(jsonData);
    return  map;
  }
}