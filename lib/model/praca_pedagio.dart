import 'package:lapis_lazuli/model/pagination_model.dart';
import 'package:lapis_lazuli/util/date_util.dart';

class PracaPedagio {
  int id;
  String nomePraca;
  String concessionaria;
  int anoPnvSnv;
  String sentido;
  String direcao;
  double latitude;
  double longitude;
  String cabineBloqueio;
  String telefone;
  DateTime dataIncioCobranca;
  String uf;
  double kmM;
  int rodovia;
  DateTime inseridoEm;
  PaginationModel pagination;

  PracaPedagio({
    this.id,
    this.nomePraca,
    this.concessionaria,
    this.anoPnvSnv,
    this.sentido,
    this.direcao,
    this.latitude,
    this.longitude,
    this.cabineBloqueio,
    this.telefone,
    this.dataIncioCobranca,
    this.uf,
    this.kmM,
    this.rodovia,
    this.inseridoEm,
    this.pagination
  });

  factory PracaPedagio.fromJson(Map<String, dynamic> json, {Map pagination}) {
    return PracaPedagio(
      id: json["id"],
      nomePraca: json["nomePraca"],
      concessionaria: json["concessionaria"],
      anoPnvSnv: json["anoPnvSnv"],
      sentido: json["sentido"],
      direcao: json["direcao"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      cabineBloqueio: json["cabineBloqueio"],
      telefone: json["telefone"],
      dataIncioCobranca:
          DateUtil.toDateFromMillisecondsSinceEpoch(json["dataIncioCobranca"]),
      uf: json["uf"],
      kmM: double.parse(json["kmM"].toString()),
      rodovia: json["rodovia"],
      inseridoEm: DateUtil.toDateFromMillisecondsSinceEpoch(json["inseridoEm"]),
        pagination: PaginationModel.fromJson(pagination),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nomePraca": nomePraca,
      "concessionaria": concessionaria,
      "anoPnvSnv": anoPnvSnv,
      "sentido": sentido,
      "direcao": direcao,
      "latitude": latitude,
      "longitude": longitude,
      "cabineBloqueio": cabineBloqueio,
      "telefone": telefone,
      "dataIncioCobranca": dataIncioCobranca,
      "uf": uf,
      "kmM": kmM,
      "rodovia": rodovia,
      "inseridoEm": inseridoEm,
    };
  }


  @override
  String toString() {
    return 'PracaPedagio{id: $id, nomePraca: $nomePraca, concessionaria: $concessionaria, '
        'anoPnvSnv: $anoPnvSnv, sentido: $sentido, direcao: $direcao, '
        'latitude: $latitude, longitude: $longitude, '
        'telefone: $telefone, '
        'uf: $uf, kmM: $kmM, rodovia: $rodovia, '
        'pagination: $pagination}';
  }

}
