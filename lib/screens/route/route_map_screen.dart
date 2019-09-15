import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lapis_lazuli/blocs/route_bloc.dart';
import 'package:lapis_lazuli/blocs/route_state.dart';
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
    final primaryColor = Theme.of(context).primaryColor;

    final googleMapsProvider = Provider.of<GoogleMapsProvider>(context);
    var size = MediaQuery.of(context).size;
    double maxHeight = size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      bottomSheet: BottomWidget(
        fullSizeHeight: maxHeight - 20,
        pracas: googleMapsProvider.pracas,
        bloc: bloc,
      ),
      body: googleMapsProvider.initialPosition == null
          ? _circularProgress()
          : Stack(
              children: <Widget>[
                StreamBuilder<RouteState>(
                    stream: bloc.outState,
                    builder: (context, snapshot) {
                      if (snapshot.data == RouteState.LOADING) {
                        return _circularProgress();
                      }
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: googleMapsProvider.initialPosition,
                            zoom: 10.0),
                        onMapCreated: googleMapsProvider.onCreated,
                        myLocationEnabled: true,
                        compassEnabled: true,
                        mapType: _currentMapType,
                        markers: googleMapsProvider.markers,
                        onCameraMove: googleMapsProvider.onCameraMove,
                        polylines: googleMapsProvider.polyLines,
                      );
                    }),

                //Origem
                _buildOrigem(googleMapsProvider),
                //Destino
                _buildDestino(googleMapsProvider),
                //Pedagios
                _buildButtonPedagio(),
                //Visao do Mapa
                _buildButtonMap(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () async {
          if (bloc.routeState == RouteState.SUCCESS) {
            bloc.resetState();
            setState(() {});
          } else if (googleMapsProvider.isRequest()) {
            bloc.routing(googleMapsProvider);
          } else {
            _showAlert();
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
      child: bloc.routeState == RouteState.LOADING ||
              bloc.routeState == RouteState.SUCCESS
          ? Container()
          : Container(
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
      child: bloc.routeState == RouteState.LOADING ||
              bloc.routeState == RouteState.SUCCESS
          ? Container()
          : Container(
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

  _buildButtonPedagio() {
    return Positioned(
      bottom: 147,
      right: 30.0,
      child: bloc.routeState == RouteState.LOADING ||
              bloc.routeState == RouteState.FAIL
          ? Container()
          : Container(
              alignment: Alignment.bottomRight,
              color: Colors.transparent,
              height: 50,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    bloc.visible();
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  _buildButtonMap() {
    return Positioned(
      bottom: 85,
      right: 30.0,
      child: bloc.routeState == RouteState.LOADING
          ? Container()
          : Container(
              alignment: Alignment.bottomRight,
              color: Colors.transparent,
              height: 50,
              child: FloatingActionButton(
                onPressed: _onMapTypeButtonPressed,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.map,
                  color: Colors.white,
                ),
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

  Widget _circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3.0,
        ),
      ),
    );
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Atenção'),
          content: Container(
            child: Text('Informe origem e destino antes de traçar a rota!'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
