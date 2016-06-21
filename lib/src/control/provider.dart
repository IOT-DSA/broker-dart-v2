part of dsa.broker;

abstract class ControlProvider {
  void registerBroker(Broker broker);

  Future init();

  Future<CompletedHandshake> shake(HandshakeRequest request);

  Future<DSLink> getLinkByPath(String owner);
  Future<DSLink> getLinkByDsId(String dsId);
  Future clearConns();

  Future authorize(DSLink link, String auth);

  Future<PrivateKey> getBrokerKey();

  Stream<DSLink> getKnownLinks();
  Stream<DSLink> getConnectedLinks();

  Future stop();

  void addEventListener(BrokerEventListener listener);
  void registerBrokerLink(BrokerLink brokerLink);
}
