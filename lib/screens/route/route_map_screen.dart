import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lapis_lazuli/blocs/route_bloc.dart';
import 'package:provider/provider.dart';
import 'package:lapis_lazuli/providers/google_maps_provider.dart';
import 'package:lapis_lazuli/widgets/google_address_input_field.dart';

import 'package:lapis_lazuli/widgets/bottom_sheet.dart';

class RouteMapScreen extends StatefulWidget {
  RouteMapScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  bool showSheet = false;
  MapType _currentMapType = MapType.normal;

//key para snack bar
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RouteBloc bloc = RouteBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final googleMapsProvider = Provider.of<GoogleMapsProvider>(context);
    double fullSizeHeight = MediaQuery
        .of(context)
        .size
        .height;

    var bottomSheet = BottomWidget(
      fullSizeHeight: fullSizeHeight-20,
      pracas: googleMapsProvider.pracas,
      bloc: bloc,
    );
    return Scaffold(
      key: _scaffoldKey,
      bottomSheet: bottomSheet,
      body: googleMapsProvider.initialPosition == null
          ? Container(
        alignment: Alignment.center,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: googleMapsProvider.initialPosition, zoom: 10.0),
            onMapCreated: googleMapsProvider.onCreated,
            myLocationEnabled: true,
            compassEnabled: true,
            mapType: _currentMapType,
            markers: googleMapsProvider.markers,
            onCameraMove: googleMapsProvider.onCameraMove,
            polylines: googleMapsProvider.polyLines,
          ),

          //Origem
          _buildOrigem(googleMapsProvider),
          //Destino
          _buildDestino(googleMapsProvider),

          Padding(
            padding: const EdgeInsets.only(bottom: 152.0, right: 30),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    bloc.visible();
                  });
                },
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 85.0, right: 30),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: _onMapTypeButtonPressed,
                child: Icon(
                  Icons.map,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        onPressed: () async {
          if (googleMapsProvider.isRequest()) {
            await googleMapsProvider
                .sendRequest(googleMapsProvider.destinationController.text);

            if(googleMapsProvider.pracas.length>0){
              bloc.visible();
            }
          } else {
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text("Informe origem e destino"),
              ),
            );
          }
        },
        label: Text('Ir'),
        icon: Icon(
          Icons.directions,
          size: 24,
        ),
      ),
    );
  }

  _buildOrigem(GoogleMapsProvider googleMapsState) {
    return Positioned(
      top: 50.0,
      right: 15.0,
      left: 15.0,
      child: Container(
        padding: EdgeInsets.only(top: 8, right: 10),
        height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 5.0),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        child: GoogleAddressInputField(
          controller: googleMapsState.locationController,
          label: "Origem",
          iconData: Icons.location_on,
          hint: "Local de origem",
        ),
      ),
    );
  }

  _buildDestino(GoogleMapsProvider googleMapsState) {
    return Positioned(
      top: 115.0,
      right: 15.0,
      left: 15.0,
      child: Container(
        padding: EdgeInsets.only(top: 8, right: 10),
        height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(1.0, 5.0),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        child: GoogleAddressInputField(
          controller: googleMapsState.destinationController,
          label: "Seu Destino",
          iconData: Icons.local_taxi,
          hint: "Local de destino",
        ),
      ),
    );
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
      } else if (_currentMapType == MapType.hybrid) {
        _currentMapType = MapType.terrain;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }
}
