part of dsa.broker.link;

class BrokerLinkEventListener extends BrokerEventListener {
  final BrokerLink brokerLink;

  BrokerLinkEventListener(this.brokerLink);

  void handleNewLink(DSLink link) {
    if (link is BrokerLink) {
      return;
    }

    var node = new SimpleNode(link.path);
    node.configs.addAll({
      r"$is": "dsa/link",
      r"$$dsId": link.dsId
    });

    brokerLink.provider.setNode(
      link.path,
      node
    );
  }
}

class BrokerLink extends DSLink {
  BrokerLink(Broker broker, String dsId) : super(
    broker,
    dsId: dsId,
    isResponder: true,
    path: "/"
  ) {
    new Future(() async {
      await init();
    });
  }

  SimpleNodeProvider provider;
  DownstreamNode downstreamNode;
  UpstreamNode upstreamNode;
  SimpleNode rootNode;

  Future init() async {
    provider = new SimpleNodeProvider();
    provider.getNode("/").configs.addAll({
      r"$is": "dsa/broker"
    });

    downstreamNode = new DownstreamNode("/downstream");
    provider.setNode(downstreamNode.path, downstreamNode);
    upstreamNode = new UpstreamNode("/upstream");
    provider.setNode(upstreamNode.path, upstreamNode);

    var conn = new VirtualBrokerConnectionProvider(provider);
    setConnection(conn);

    broker.control.addEventListener(new BrokerLinkEventListener(this));
  }
}
