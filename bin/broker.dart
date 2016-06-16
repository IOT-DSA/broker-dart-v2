import "package:dsbroker/broker.dart";

main(List<String> args) async {
  var launcher = new BrokerLauncher(args, <BrokerLauncherExtension>[]);
  await launcher.launch();
}
