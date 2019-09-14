import 'package:google_maps_flutter/google_maps_flutter.dart';

class Routes {

  ///Coordenadas detalhada da rotada
  ///latitude, longitude, tempo e duração de cada ponto
  RouteLeg legs;

  ///Pontos para desenhar a rota (Criptografados)
  String overviewPolyline;
  GeocodedWaypoints waypointsOrigin;
  GeocodedWaypoints waypointsDestiny;
  List<LatLng> latLngList;

  Routes({
    this.legs,
    this.overviewPolyline,
    this.waypointsOrigin,
    this.waypointsDestiny
  });

  factory Routes.fromJson(Map json) {
    return Routes(
      legs: RouteLeg.fromJson(json["routes"][0]["legs"][0]),
      overviewPolyline: json["routes"][0]["overview_polyline"]["points"],
      waypointsOrigin: GeocodedWaypoints.fromJson( json["geocoded_waypoints"][0]),
      waypointsDestiny: GeocodedWaypoints.fromJson( json["geocoded_waypoints"][1]),
    );
  }
}

class GeocodedWaypoints {

  String placeId;

  GeocodedWaypoints({this.placeId});

  factory GeocodedWaypoints.fromJson(Map map){
    if(map == null){
      return null;
    }
    return GeocodedWaypoints(
      placeId: map["place_id"]
    );
  }

}

class RouteLatLng {
  double lat;
  double lng;
  LatLng latLng;

  RouteLatLng({
    this.lat,
    this.lng,
  });

  factory RouteLatLng.fromJson(Map json) {
    var r = RouteLatLng(
      lat: json["lat"],
      lng: json["lng"],
    );
    r.latLng = LatLng(r.lat, r.lng);
    return r;
  }
}

class RouteLeg {
  RouteDistance distance;
  RouteDistance duration;
  String endAddress;
  RouteLatLng endLocation;
  String startAddress;
  RouteLatLng startLocation;
  List<RouteStep> steps;

  RouteLeg({
    this.distance,
    this.duration,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
    this.steps,
  });

  factory RouteLeg.fromJson(Map json) {
    var steps = List<RouteStep>();

    for (int i = 0; i < json["steps"].length; i++) {
      steps.add(RouteStep.fromJson(json["steps"][i]));
    }

    return RouteLeg(
      distance: RouteDistance.fromJson(json["distance"]),
      duration: RouteDistance.fromJson(json["duration"]),
      endAddress: json["end_address"],
      endLocation: RouteLatLng.fromJson(json["end_location"]),
      startAddress: json["start_address"],
      startLocation: RouteLatLng.fromJson(json["start_location"]),
      steps: steps,
    );
  }
}

class RouteDistance {
  String km;
  int miles;

  RouteDistance({
    this.km,
    this.miles,
  });

  factory RouteDistance.fromJson(Map json) {
    return RouteDistance(
      km: json["text"],
      miles: json["value"],
    );
  }
}

class RouteStep {
  RouteDistance distance;
  RouteDistance duration;
  RouteLatLng endLocation;
  String htmlInstructions;
  String polyline;
  RouteLatLng startLocation;
  String travelMode;
  String maneuver;
  int polylineCount;
  String address;

  RouteStep({
    this.distance,
    this.duration,
    this.endLocation,
    this.htmlInstructions,
    this.polyline,
    this.startLocation,
    this.travelMode,
    this.maneuver,
  });

  factory RouteStep.fromJson(Map json) {
    if (json["polyline"].length > 1) {
      throw Exception(
          "Avis -> Polyline possui mais de um ponto e não foi mapeado"
          " ${json["polyline"].length}");
    }

    var step = RouteStep(
      distance: RouteDistance.fromJson(json["distance"]),
      duration: RouteDistance.fromJson(json["duration"]),
      endLocation: RouteLatLng.fromJson(json["end_location"]),
      startLocation: RouteLatLng.fromJson(json["start_location"]),
      htmlInstructions: json["html_instructions"],
      polyline: json["polyline"]["points"],
      travelMode: json["travel_mode"],
      maneuver: json["maneuver"],
    );

    return step;
  }
}
