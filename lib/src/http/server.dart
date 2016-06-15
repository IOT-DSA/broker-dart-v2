part of dsa.broker;

class BrokerHttpServer {
  final Broker broker;

  HttpServer _server;

  BrokerHttpServer(this.broker);

  Future<HttpServer> startHttpServer({int port: 8080, host: "0.0.0.0"}) async {
    var server = await HttpServer.bind(host, port);
    await useHttpServer(server);
    return server;
  }

  Future useHttpServer(HttpServer server) async {
    _server = server;

    server.listen(handleRequest);
  }

  Future stop() async {
    if (_server == null) {
      return;
    }

    await _server.close();
  }

  Future handleRequest(HttpRequest request) async {
    try {
      var uri = request.uri;

      if (uri.path == "/conn") {
        await handleConnRequest(request);
      } else if (uri.path == "/ws") {
        await handleWebSocketRequest(request);
      } else {
        await HttpUtils.sendNotFound(request);
      }
    } catch (e, stack) {
      if (e is BrokerClientException) {
        await HttpUtils.sendBadRequest(request, e.toString());
      } else {
        broker.logger.warning(
          "HTTP Request to ${request.uri} encountered an error.",
          e,
          stack
        );
        await HttpUtils.sendServerError(request, e.toString());
      }
    }
  }

  Future handleConnRequest(HttpRequest request) async {
    var uri = request.uri;

    var dsId = uri.queryParameters["dsId"];
    var token = uri.queryParameters["token"];
    var session = uri.queryParameters["session"];

    if (dsId == null || dsId.length < 43) {
      return await HttpUtils.sendBadRequest(request, _getDsIdErrorMsg(dsId));
    }

    var json = await HttpUtils.readJsonRequest(request);
    var handshakeRequest = new HandshakeRequest.decode(
      json,
      dsId: dsId,
      token: token,
      session: session
    );

    var shaken = await broker.control.shake(
      handshakeRequest
    );

    await HttpUtils.writeJsonResponse(
      request,
      shaken.response.encode()
    );
  }

  Future handleWebSocketRequest(HttpRequest request) async {
    var uri = request.uri;
    var dsId = uri.queryParameters["dsId"];
    var auth = uri.queryParameters["auth"];

    if (dsId == null || dsId.length < 43) {
      return await HttpUtils.sendBadRequest(request, _getDsIdErrorMsg(dsId));
    }

    var link = await broker.control.getLinkByDsId(dsId);

    if (link == null) {
      throw new BrokerClientException("Handshake not completed.");
    }

    await broker.control.authorize(link, auth);

    var socket = await WebSocketTransformer.upgrade(request);
    link.setConnection(new WebSocketProvider(socket));
  }

  String _getDsIdErrorMsg(String dsId) {
    if (dsId == null) {
      return "dsId is missing.";
    } else if (dsId.isEmpty) {
      return "dsId is empty.";
    } else if (dsId.length < 43) {
      return "dsId is less than 43 characters.";
    } else {
      return "Unknown dsId error.";
    }
  }
}
