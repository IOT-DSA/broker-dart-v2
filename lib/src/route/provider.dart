part of dsa.broker;

abstract class RouteProvider {
  void registerBroker(Broker broker);
  Future init();

  Future handle(Link link, List<DSPacket> packets);
}
