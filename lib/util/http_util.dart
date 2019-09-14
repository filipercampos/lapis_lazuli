import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpUtil {
  ///Response padrão da API é um map: data
  static Map<String, dynamic> decodeApi(http.Response response) {
    var data = decode(response);
    if (data != null) {
      return data;
    }
    return {"data": null};
  }

  static Map<String, dynamic> decode(http.Response response) {
    var decode = json.decode(response.body);
    print("API response: ${response.statusCode}");
    print(response.reasonPhrase ?? "");
    return decode;
  }
}
