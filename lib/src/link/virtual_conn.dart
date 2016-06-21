part of dsa.broker.link;

class BrokerResponder extends Responder {
  final DSLink link;

  BrokerResponder(this.link, NodeProvider nodeProvider) :
      super(nodeProvider);

  @override
  void addToSendList(DSPacket pkt) {
    link.handlePackets([pkt]);
  }
}

class VirtualBrokerConnectionProvider extends ConnectionProvider {
  final NodeProvider provider;

  BrokerResponder _responder;

  VirtualBrokerConnectionProvider(this.provider);

  DSLink _link;

  @override
  void registerLink(DSLink link) {
    _link = link;

    _responder = new BrokerResponder(_link, provider);
  }

  @override
  void send(List<DSPacket> packets) {
    if (_responder == null) {
      return;
    }

    for (DSPacket pkt in packets) {
      _responder.onData(pkt);
    }
  }

  Completer _completer = new Completer();

  @override
  void disconnect() {
    _completer.complete();
  }

  @override
  Future get onDisconnect {
    return _completer.future;
  }
}
