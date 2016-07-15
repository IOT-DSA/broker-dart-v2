import "package:dsbroker/broker.dart";
import 'dart:async';

Future<Null> main(List<String> args) async {
  var launcher = new BrokerLauncher(args, <BrokerLauncherExtension>[]);
  await launcher.launch();
}
