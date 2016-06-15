part of dsa.broker.utils;

class HttpUtils {
  static Future<dynamic> readJsonRequest(HttpRequest request) async {
    return const JsonDecoder().convert(await readStringRequest(request));
  }

  static Future<String> readStringRequest(HttpRequest request) async {
    return const Utf8Decoder().convert(await readBytesRequest(request));
  }

  static Future<List<int>> readBytesRequest(HttpRequest request) async {
    return await request.fold(<int>[], (List<int> a, List<int> b) {
      return a..addAll(b);
    });
  }

  static Future sendBadRequest(HttpRequest request, String message) async {
    var response = request.response;

    response.statusCode = HttpStatus.BAD_REQUEST;
    response.writeln(message);
    await response.close();
  }

  static Future sendServerError(HttpRequest request, String message) async {
    var response = request.response;

    response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    response.writeln(message);
    await response.close();
  }

  static Future sendNotFound(HttpRequest request) async {
    var response = request.response;

    response.statusCode = HttpStatus.NOT_FOUND;
    response.writeln("404 - Not Found.");
    await response.close();
  }

  static Future writeJsonResponse(HttpRequest request, dynamic json) async {
    var response = request.response;
    var encoded = const JsonEncoder().convert(json);

    response.writeln(encoded);
    await response.close();
  }
}
