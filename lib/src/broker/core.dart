part of dsa.broker;

class Broker {
  final StorageProvider storage;
  final ControlProvider control;
  final RouteProvider route;
  final Logger logger;

  BrokerHttpServer httpServer;

  Broker(this.control, this.storage, this.route, this.logger);

  Future<BrokerHttpServer> setupHttpServer({int port: 8080, host: "0.0.0.0"}) async {
    httpServer = new BrokerHttpServer(this);
    await httpServer.startHttpServer(host: host, port: port);
    return httpServer;
  }

  void init() {
    control.registerBroker(this);
    route.registerBroker(this);
  }
}
