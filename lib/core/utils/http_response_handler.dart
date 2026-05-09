import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpResponseHandler {
  // -------------------- Validar respuesta HTTP --------------------
  static void validate({
    required http.Response response,
    required List<int> expectedStatusCodes,
    required String errorMessage,
  }) {
    // verifica si el status code recibido está dentro de los esperados
    if (!expectedStatusCodes.contains(response.statusCode)) {
      throw Exception('$errorMessage (${response.statusCode})');
    }
  }

  // -------------------- Decodifica JSON seguro --------------------
  static dynamic decode(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  // -------------------- Decodifica lista --------------------
  static List<dynamic> decodeList(http.Response response) {
    final data = jsonDecode(response.body);
    return (data as List);
  }
}
