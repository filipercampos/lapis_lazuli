import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lapis_lazuli/controllers/praca_pedagio_controller.dart';
import 'package:location/location.dart';
import 'package:lapis_lazuli/controllers/google_maps_controller.dart';
import 'package:lapis_lazuli/model/praca_pedagio.dart';
import 'package:lapis_lazuli/model/routes.dart';
import 'package:lapis_lazuli/values/color_values.dart';

class GoogleMapsProvider with ChangeNotifier {
  ///My Current Location
  static LatLng _initialPosition;
  LatLng _lastPosition = _initialPosition;
  final Set<Marker> _markers = Set<Marker>();
  final Set<Polyline> _polyLines = Set<Polyline>();
  GoogleMapController _mapController;
  GoogleMapsController _googleMapsController = GoogleMapsController();
  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  CameraPosition lastCameraPosition;
  Routes _route;

  ///Localização atual
  LatLng get initialPosition => _initialPosition;

  ///Última posição definido no mapa pelo usuário
  LatLng get lastPosition => _lastPosition;

  ///Serviço de busca de direções do google
  GoogleMapsController get googleMapsServices => _googleMapsController;

  ///Controlador do mapa do google
  GoogleMapController get mapController => _mapController;

  ///Marcadores
  Set<Marker> get markers => _markers;

  ///Coordenadas para desenhar a orta
  Set<Polyline> get polyLines => _polyLines;

  ///Praças de pedagios
  List<PracaPedagio> pracas = List<PracaPedagio>();

  LatLng _latLngOrigination;
  LatLng _latLngDestiny;

  GoogleMapsProvider() {
    _getUserLocation();

  }

  ///Seta a localização atual
  void _getUserLocation() async {
    if (_initialPosition == null) {
      var location = new Location();
      var position = await location.getLocation();
//    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      try {
        List<Placemark> placemark = await Geolocator()
            .placemarkFromCoordinates(position.latitude, position.longitude);
        _initialPosition = LatLng(position.latitude, position.longitude);
        print("initial position is : ${_initialPosition.toString()}");
        var place = placemark[0];

        locationController.text = "${place.thoroughfare}, ${place.name}, "
            "${place.subLocality}, ${place.postalCode}, "
            "${place.subAdministrativeArea}, ${place.administrativeArea}";
      } catch (error) {
        debugPrint(error);
      }

      notifyListeners();
    }
  }

  ///Add um marker (Alfinete)
  void _addMarker(LatLng location, String address,
      {String snippet = "", BitmapDescriptor marker}) {
    _markers.add(
      Marker(
        markerId: MarkerId(location.toString() /*_lastPosition.toString()*/),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: snippet),
        icon: marker == null
            ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              )
            : marker,
      ),
    );
    notifyListeners();
  }

  ///Adiciona um Markers azul
  void addMarker(LatLng location, String address,
      {String snippet = "", BitmapDescriptor marker}) {
    markers.add(
      Marker(
        markerId: MarkerId(location.toString() /*_lastPosition.toString()*/),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: snippet),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );
  }

  ///Constroi lat/lng a partir do placemark
  _buildLatLng(Placemark placemark) {
    double latitude = placemark.position.latitude;
    double longitude = placemark.position.longitude;
    return LatLng(latitude, longitude);
  }

  ///Solicita criação da rota e seta os markers
  Future<Null> sendRequest(String intendedLocation) async {
    //remove todos os markers anteriores
    _markers.clear(); //marker origin

    List<Placemark> placemarkOrigination =
        await Geolocator().placemarkFromAddress(locationController.text);
    LatLng origination = _buildLatLng(placemarkOrigination[0]);
    this._latLngOrigination = origination;

    //marker destiny
    List<Placemark> placemarkDestiny =
        await Geolocator().placemarkFromAddress(intendedLocation);
    LatLng destination = _buildLatLng(placemarkDestiny[0]);
    this._latLngDestiny = destination;

    _addMarker(_latLngOrigination, locationController.text, snippet: "Origem");
    _addMarker(_latLngDestiny, intendedLocation, snippet: "Destino");

    ///decodifica as polilinhas
    this._route = await _googleMapsController.getRouteCoordinates(
      _latLngOrigination,
      _latLngDestiny,
    );

    ///Cria a rota
    String encondedPoly = _route.overviewPolyline;
    final latLngList =
        googleMapsServices.getLatLngListFromOverviewPolyline(encondedPoly);
    _route.latLngList = latLngList;

    _polyLines.clear();

    _polyLines.add(
      Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: latLngList,
        color: ColorValues.primaryColor,
      ),
    );

    notifyListeners();

    debugPrint("Route created !");

    await _buildMarkerOfPracas();
  }

  ///Marcadores para as praças de pedágio
  Future<Null> _buildMarkerOfPracas() async {
    ///lista de coordenadas que foram decodificadas
    this.pracas = await googleMapsServices.buildPracasFromPolyline(_route.latLngList);

    for (int i = 0; i < pracas.length; i++) {
      var p = pracas[i];

      var latLng = LatLng(p.latitude, p.longitude);

      print("Build marker from $p");
      addMarker(
        latLng,
        "${p.concessionaria} / ${p.nomePraca}",
        snippet: "${p.rodovia} - KM ${p.kmM}",
        marker: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
    }
    notifyListeners();

    debugPrint("Pedagios created !");
  }

  ///Movimentação da camera
  void onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
    lastCameraPosition = position;
    notifyListeners();
  }

  ///Cria o mapa
  void onCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
    _goToMyLocation();
  }

  ///Reposiciona o zoom do mapa
  void animateCamera(LatLng latLng ) {
    final CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      tilt: 50.0,
      bearing: 45.0,
      zoom: 9,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  ///Reposiciona o zoom do mapa na localização atual
  void _goToMyLocation() {
    animateCamera(_initialPosition);
  }
  ///Reposiciona o zoom do mapa no destino
  void centerMap() {
    final CameraPosition cameraPosition = CameraPosition(
      target: _latLngOrigination,
      tilt: 50.0,
      bearing: 45.0,
      zoom: 7.5,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  ///Reposiciona o zoom do mapa no destino
  void goToDestiny() {
//    mapController.animateCamera(
//      CameraUpdate.newLatLngZoom(
//        _latLngDestiny,
//        10,
//      ),
//    );

    final CameraPosition cameraPosition = CameraPosition(
      target: _latLngDestiny,
      tilt: 50.0,
      bearing: 60.0,
      zoom: 10.0,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  ///Reposiciona o zoom do mapa no destino
  void goToOrigin() {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        _latLngOrigination,
        13.5,
      ),
    );
  }

  ///Zoom no mapa
  void zoomInMap() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  ///Verfica se origem de destino foi definidos
  bool isRequest() {
    return locationController.text.isNotEmpty &&
        destinationController.text.isNotEmpty;
  }
}
