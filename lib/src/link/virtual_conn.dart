part of dsa.broker.link;

class _FakeLinkConnection extends Connection {
  final VirtualBrokerConnectionProvider provider;

  Map<String, dynamic> _serverCommand;

  _FakeLinkConnection(this.provider) {
    requesterChannel = new PassiveChannel(this);
    responderChannel = new PassiveChannel(this);
  }

  @override
  void addConnCommand(String key, Object value) {
    if (_serverCommand == null) {
      _serverCommand = {};
    }
    if (key != null) {
      _serverCommand[key] = value;
    }

    requireSend();
  }

  Completer _completer;

  @override
  void close() {
    _completer.complete();
  }

  @override
  Future<bool> get onDisconnected => _completer.future;

  @override
  Future<ConnectionChannel> get onRequesterReady =>
    new Future.value(requesterChannel);

  @override
  PassiveChannel requesterChannel;

  @override
  PassiveChannel responderChannel;

  @override
  void requireSend() {
    if (!_sending) {
      _sending = true;
      DSUtils.DsTimer.callLater(_send);
    }
  }

  bool _sending = false;

  void _send() {
    _sending = false;

    bool needSend = false;

    var pkts = <DSPacket>[];

    if (_serverCommand != null) {
      if (_serverCommand["ack"] is int) {
        var pkt = new DSAckPacket();
        pkt.ackId = _serverCommand["ack"];
        _serverCommand = null;
        addPackets([pkt]);
        requireSend();
        return;
      } else {
        needSend = true;
        _serverCommand = null;
      }
    }

    var pendingAck = <ConnectionProcessor>[];
    int ts = (new DateTime.now()).millisecondsSinceEpoch;
    ProcessorResult rslt = responderChannel.getSendingData(ts, nextMsgId);
    if (rslt != null) {
      if (rslt.messages.length > 0) {
        needSend = true;

        for (DSPacket pkt in rslt.messages) {
          if (pkt is DSNormalPacket && pkt.isLargePayload()) {
            pkts.addAll(pkt.split());
          } else {
            pkts.add(pkt);
          }
        }
      }

      if (rslt.processors.length > 0) {
        pendingAck.addAll(rslt.processors);
      }
    }
    rslt = requesterChannel.getSendingData(ts, nextMsgId);

    if (rslt != null) {
      if (rslt.messages.length > 0) {
        needSend = true;

        for (DSPacket pkt in rslt.messages) {
          if (pkt is DSNormalPacket && pkt.isLargePayload()) {
            pkts.addAll(pkt.split());
          } else {
            pkts.add(pkt);
          }
        }
      }

      if (rslt.processors.length > 0) {
        pendingAck.addAll(rslt.processors);
      }
    }

    if (needSend) {
      if (nextMsgId != -1) {
        if (pendingAck.length > 0) {
          pendingAcks.add(new ConnectionAckGroup(nextMsgId, ts, pendingAck));
        }

        var pkt = new DSMsgPacket();
        pkt.ackId = nextMsgId;

        if (nextMsgId < 0x7FFFFFFF) {
          ++nextMsgId;
        } else {
          nextMsgId = 1;
        }

        // Consider where the msg packet is, adding it last is best
        // if we hit a frame limit.
        pkts.add(pkt);
      }
    }

    addPackets(pkts);
  }

  int nextMsgId = 1;

  void addPackets(List<DSPacket> pkts) {
    provider._link.broker.route.handle(provider._link, pkts);
  }
}

class VirtualBrokerConnectionProvider extends ConnectionProvider {
  final NodeProvider provider;

  VirtualBrokerConnectionProvider(this.provider);

  DSLink _link;
  _FakeLinkConnection _linkConnection;
  Responder _responder;

  @override
  void registerLink(DSLink link) {
    _link = link;
    _linkConnection = new _FakeLinkConnection(this);
    _responder = new Responder(provider);
    _responder.connection = _linkConnection.responderChannel;
  }

  @override
  void send(List<DSPacket> packets) {
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
