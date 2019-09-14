import 'package:lapis_lazuli/api/api_pedagio.dart';
import 'package:lapis_lazuli/config/api_resources.dart';
import 'package:lapis_lazuli/model/praca_pedagio.dart';
import 'package:lapis_lazuli/api/iapi.dart';

class PracaPedagioController extends ApiPedagio implements IApi<PracaPedagio> {
  PracaPedagioController() : super(ApiResources.PRACAS_PEGADIO);

  @override
  Future<List<PracaPedagio>> getAll() async {
    final maps = await this.getResource("$resource");
    List<PracaPedagio> result = maps["data"]["results"].map<PracaPedagio>(
          (json) {
        return PracaPedagio.fromJson(json, pagination: maps);
      },
    ).toList();
    return result;
  }

  @override
  Future<PracaPedagio> getById(int id) async {
    final map = await this.getResource("$resource/$id");
    final mapPracaPedagio = map["data"];
    return PracaPedagio.fromJson(mapPracaPedagio);
  }

  @override
  Future<int> post(PracaPedagio body, {Map headers}) async {
    final map = await this.postResource(
      resource,
      body: body.toJson(),
      headers: headers,
    );
    if (map == null) return null;
    return map["data"]["insertId"];
  }

  @override
  Future<int> delete(int id, {Map headers}) async {
    return await this.deleteResource(
      "$resource/$id",
      headers: headers,
    );
  }

  @override
  Future<int> patch(int id, {PracaPedagio body, Map headers}) async {
    return await this.patchResource(
      "$resource/$id",
      body: body.toJson(),
      headers: headers,
    );
  }

  @override
  Future<int> put(int id, {PracaPedagio body, Map headers}) async {
    return await this.putResource(
      "$resource/$id",
      body: body.toJson(),
      headers: headers,
    );
  }
}
