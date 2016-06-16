import "package:dsbroker/broker.dart";
import "package:dslink/utils.dart" show logger;

import "dart:io";

main() async {
  var control = new DefaultControlProvider();
  var route = new DefaultRouteProvider();
  var json = new JsonDirectoryStorageProvider(new Directory("storage"));
  var broker = new Broker(control, json, route, logger);

  broker.init();
  await broker.setupHttpServer();
}
