part of dsa.broker;

class Broker {
  final StorageProvider storage;
  final ControlProvider control;
  final ConfigurationProvider config;
  final RouteProvider route;
  final Logger logger;

  BrokerHttpServer httpServer;

  Broker(this.control, this.config, this.storage, this.route, this.logger);

  Future<BrokerHttpServer> setupHttpServer({int port: 8080, host: "0.0.0.0"}) async {
    httpServer = new BrokerHttpServer(this);
    await httpServer.startHttpServer(host: host, port: port);
    return httpServer;
  }

  Future init() async {
    control.registerBroker(this);
    route.registerBroker(this);

    await storage.init();
    await control.init();
    await route.init();
  }
}
