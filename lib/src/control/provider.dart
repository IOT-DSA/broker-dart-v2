part of dsa.broker;

abstract class ControlProvider {
  Future<CompletedHandshake> shake(HandshakeRequest request);

  Future<Link> getLinkByPath(String owner);
  Future<Link> getLinkByDsId(String dsId);

  Future authorize(Link link, String auth);

  Future<PrivateKey> getBrokerKey();

  void registerBroker(Broker broker);
}
