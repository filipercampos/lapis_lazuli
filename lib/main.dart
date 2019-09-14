import 'package:flutter/material.dart';
import 'package:lapis_lazuli/providers/google_maps_provider.dart';
import 'package:lapis_lazuli/screens/route/route_map_screen.dart';
import 'package:provider/provider.dart';

import 'package:lapis_lazuli/widgets/bottom_sheet.dart';

void main() {
  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(builder: (_) => GoogleMapsProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps',
      theme: ThemeData(
        primarySwatch: Colors.black,
      ),
      home: RouteMapScreen(),
    );
  }
}

