import 'dart:convert';
import 'dart:io';

import 'package:lapis_lazuli/config/app_constants.dart';
import 'package:lapis_lazuli/model/pagination_model.dart';
import 'package:lapis_lazuli/util/http_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class ApiPedagio {
  ///Nome do recurso a ser invocado
  final String resource;

  ///Paginação
  ///Caso o recurso nao possua paginação não irá páginar
  ///Retorna null
  PaginationModel _pagination;

  ApiPedagio(this.resource);

  getResource(String resource, {Map<String, dynamic> headers}) async {
    http.Response response = await http.get(
      _buildUrl(resource),
      headers: headers,
    );

    return HttpUtil.decodeApi(response);
  }

  postResource(String resource,
      {@required Map<String, dynamic> body,
      Map<String, dynamic> headers}) async {
    final url = Uri.parse(_buildUrl(resource));

    http.Response response = await http.post(
      url,
      headers: _buildDefaulHeaders(headers),
      body: json.encode(body),
    );
    //_postHttpClientResponse(resource, body: body);

    return HttpUtil.decodeApi(response);
  }
  ///https://stackoverflow.com/questions/50278258/http-post-with-json-on-body-flutter-dart
  _postHttpClientResponse(String resource,
      {@required Map<String, dynamic> body,
      Map<String, dynamic> headers}) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse(_buildUrl(resource)));
    //request.headers.set('content-type', 'application/json');

    request.add(utf8.encode(json.encode(body)));
    HttpClientResponse response = await request.close();

    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
  }

  putResource(
    String resource, {
    Map<String, dynamic> body,
    Map<String, dynamic> headers,
  }) async {
    http.Response response = await http.put(
      _buildUrl(resource),
      body: json.encode(body),
      headers: _buildDefaulHeaders(headers),
    );

    return HttpUtil.decodeApi(response);
  }

  patchResource(
    String resource, {
    Map<String, dynamic> body,
    Map<String, dynamic> headers,
  }) async {
    http.Response response = await http.patch(
      _buildUrl(resource),
      body: json.encode(body),
      headers: _buildDefaulHeaders(headers),
    );

    return HttpUtil.decodeApi(response);
  }

  deleteResource(
    String resource, {
    Map<String, dynamic> headers,
  }) async {
    http.Response response =
        await http.delete(_buildUrl(resource), headers: headers);

    return HttpUtil.decodeApi(response);
  }

  ///Pagina o recurso a ser chamado
  void pagination(int numPage, int numRows) {
    this._pagination =
        PaginationModel.pagination(numPage: numPage, numRows: numRows);
  }

  _buildUrl(resource) {
    return "${AppConstants.URL_API}$resource/${_pagination ?? ""}";
  }

  _buildDefaulHeaders(Map headers) {
    if (headers == null) {
      return {"Accept": "application/json", "Content-Type": "application/json"};
    }
    return headers;
  }
}
