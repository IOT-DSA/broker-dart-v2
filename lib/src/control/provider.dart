part of dsa.broker;

abstract class ControlProvider {
  void registerBroker(Broker broker);

  Future init();

  Future<CompletedHandshake> shake(HandshakeRequest request);

  Future<Link> getLinkByPath(String owner);
  Future<Link> getLinkByDsId(String dsId);
  Future clearConns();

  Future authorize(Link link, String auth);

  Future<PrivateKey> getBrokerKey();

  Stream<Link> getKnownLinks();
  Stream<Link> getConnectedLinks();
}
