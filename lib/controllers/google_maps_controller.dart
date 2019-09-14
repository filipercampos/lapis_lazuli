import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lapis_lazuli/config/app_constants.dart';
import 'package:lapis_lazuli/controllers/praca_pedagio_controller.dart';
import 'package:lapis_lazuli/model/geocode_address.dart';
import 'package:lapis_lazuli/model/praca_pedagio.dart';
import 'package:lapis_lazuli/model/routes.dart';
import 'package:lapis_lazuli/util/number_util.dart';

class GoogleMapsController {
  ///Recupera as polylines para desenhar a rota
  Future<Routes> getRouteCoordinates(LatLng l1, LatLng l2) async {
    final baseUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=";
    String url = "$baseUrl${l1.latitude},${l1.longitude}&destination="
        "${l2.latitude},${l2.longitude}"
        "&key=${AppConstants.MAPS_API_KEY}";
    http.Response response = await http.get(url);
    Map json = jsonDecode(response.body);

    var routes = Routes.fromJson(json);
    //    return json["routes"][0]["overview_polyline"]["points"];
    return routes;
  }

  Future<List<dynamic>> getAddressList(String addressPart) async {
    List<Address> addressList =
        await Geocoder.local.findAddressesFromQuery(addressPart);
    return addressList;
  }

  static Future<GeocodeAddress> getAddressFromLatLng(LatLng latLng) async {
    var baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?";
    var url = "${baseUrl}latlng=${latLng.latitude},${latLng.longitude}&"
        "key=${AppConstants.MAPS_API_KEY}";

    http.Response response = await http.get(url);
    Map json = jsonDecode(response.body);

    GeocodeAddress address = GeocodeAddress.fromJson(json);
//    return json["results"][0]["formatted_address"] ;
    return address;
  }

  ///Cria uma lista de endereços a partir da polyline
  ///Verifica se a latitude e longitude é uma praça de pedagio
  Future<List<PracaPedagio>> buildPracasFromPolyline(
      List<LatLng> latLngList) async {
    //otmizando as requisições na api do google
    PracaPedagioController controller = PracaPedagioController();
    //toda as praças disponiveis
    var allPracas = await controller.getAll();

    //praças que vao receber o marker
    var pracas = List<PracaPedagio>();

    //percorrendo a lista de coordenadas
    latLngList.forEach(
      (l) {
        allPracas.forEach(
          (p) {
            var latBase = NumberUtil.toDouble(l.latitude.toStringAsFixed(5));
            var lngBase = NumberUtil.toDouble(l.longitude.toStringAsFixed(5));

            var lat = NumberUtil.toDouble(p.latitude.toStringAsFixed(5));
            var lng = NumberUtil.toDouble(p.longitude.toStringAsFixed(5));

            var diffLat = _rangeLatitude(latBase ,lat);
            var diffLng = _rangeLatitude(lngBase , lng);
            //latBase.toStringAsFixed(3) == lat.toStringAsFixed(3)

            if (diffLat && diffLng) {
              //guarde e atualize a coordenada (evita chamada do google)
              p.latitude = l.latitude;
              p.longitude = l.longitude;
              pracas.add(p);
            }
          },
        );
      },
    );
    //removendo duplicações de coordenadas
    var result = List<PracaPedagio>();
    if (pracas.length > 0) {
      var praca = pracas[0];
      result.add(praca);
      for (int i = 1; i < pracas.length; i++) {
        var p = pracas[i];
        if (p.id != praca.id) {
          result.add(p);
        }
      }
    }
    return result;
  }

  bool _rangeLatitude(lat1, lat2) {
    var diff = lat1 - lat2;
    diff = diff < 0.0 ? diff * -1.0 : diff;

    if (diff < 0.009 && diff > 0.00010) {
//      print("lat base ok $diff");
      return true;
    }
    //print("error $diff");
    return false;
  }

  ///Recupera as coordenadas para desenhar a rota do mapa
  List<LatLng> getLatLngListFromOverviewPolyline(
      String overviewPolylinePoints) {
    var latLngList = _convertToLatLng(
      _decodePoly(overviewPolylinePoints),
    );
    return latLngList;
  }

  ///Cria a lista de latitude de longitude
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  ///Decode polyline
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    // repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];
    //print(lList.toString());
    return lList;
  }
}
