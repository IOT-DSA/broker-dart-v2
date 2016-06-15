import "package:dsbroker/broker.dart";
import "package:dslink/utils.dart" show logger;

main() async {
  var control = new DefaultControlProvider();
  var route = new DefaultRouteProvider();
  var broker = new Broker(control, route, logger);

  broker.init();
  await broker.setupHttpServer();
}
