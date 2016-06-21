part of dsa.broker;

abstract class RouteProvider {
  void registerBroker(Broker broker);
  Future init();

  Future handle(DSLink link, List<DSPacket> packets);

  Future stop();
}
