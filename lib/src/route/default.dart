part of dsa.broker;

class DefaultRouteProvider extends RouteProvider {
  static const List<String> linkPoints = const <String>[
    "/downstream/",
    "/upstream/",
    "/sys/quarantine/"
  ];

  Broker _broker;
  List<_RouteAckGroup> _ackGroups = [];

  @override
  void registerBroker(Broker broker) {
    _broker = broker;
  }

  @override
  Future init() async {
  }

  @override
  handle(DSLink sourceLink, List<DSPacket> packets) async {
    var deliverQueue = <DSLink, List<DSPacket>>{};
    var msgs = <DSMsgPacket>[];
    var acks = <DSAckPacket>[];

    pub(DSLink link, DSPacket pkt) {
      print("${sourceLink.dsId} => ${pkt} => ${link.dsId}");

      if (sourceLink != link) {
        if (pkt is DSRequestPacket) {
          pkt.rid = link.translator.translateRequest(pkt.rid, sourceLink.dsId);
        } else if (pkt is DSResponsePacket) {
          pkt.rid = link.translator.translateResponse(pkt.rid);
        }
      }

      var list = deliverQueue[link];

      if (list == null) {
        list = deliverQueue[link] = <DSPacket>[];
      }

      list.add(pkt);
    }

    for (DSPacket packet in packets) {
      if (packet is DSMsgPacket) {
        msgs.add(packet);
      } else if (packet is DSAckPacket) {
        acks.add(packet);
      } else if (packet is DSRequestPacket && sourceLink.isRequester) {
        var path = packet.path;
        var route = describe(path);
        var link = await _broker.control.getLinkByPath(route.owner);

        if (link == null) {
          var resp = new DSResponsePacket();
          resp.rid = packet.rid;
          resp.method = DSPacketMethod.close;
          resp.mode = DSPacketResponseMode.closed;
          resp.setPayload({
            "type": "disconnected"
          });
          pub(sourceLink, resp);
        } else {
          packet.path = path;
          pub(link, packet);
        }
      } else if (packet is DSResponsePacket && sourceLink.isResponder) {
        var targetDsId = sourceLink.translator.translateResponseRoute(
          packet.rid
        );

        var link = await _broker.control.getLinkByDsId(
          targetDsId
        );

        if (link == null) {
          var req = new DSRequestPacket();
          req.rid = packet.rid;
          req.method = DSPacketMethod.close;
          req.setPayload({
            "type": "disconnected"
          });
          pub(sourceLink, req);
        } else {
          pub(link, packet);
        }
      }
    }

    for (DSMsgPacket pkt in msgs) {
      var out = <DSLink, int>{};
      for (DSLink link in deliverQueue.keys) {
        out[link] = link.translator.getNextAckId();
      }
      _ackGroups.add(new _RouteAckGroup(this, out, sourceLink, pkt.ackId));
    }

    for (DSAckPacket pkt in acks) {
      for (_RouteAckGroup group in _ackGroups.toList()) {
        group.recv(sourceLink, pkt.ackId);
      }
    }

    if (_broker.logger.isLoggable(Level.FINEST)) {
      _broker.logger.finest("Deliver: ${deliverQueue}");
    }

    for (DSLink link in deliverQueue.keys) {
      if (link.isConnected) {
        link.connection.send(deliverQueue[link]);
      }
    }
  }

  RouteDescription describe(String path) {
    for (String point in linkPoints) {
      if (path.startsWith(point)) {
        var owner = path.substring(0, path.indexOf("/", point.length + 1));
        var target = path.substring(owner.length);

        return new RouteDescription(owner, target);
      }
    }

    return new RouteDescription("/", path);
  }

  @override
  Future stop() async {
  }
}

class _RouteAckGroup {
  final DefaultRouteProvider route;
  final Map<DSLink, int> acks;
  final DSLink target;
  final int sendAckId;

  int _got = 0;

  _RouteAckGroup(this.route, this.acks, this.target, this.sendAckId);

  void recv(DSLink link, int ackId) {
    var expect = acks[link];
    if (expect == ackId) {
      _got++;
    }

    if (_got == acks.length) {
      if (target.isConnected) {
        var ack = new DSAckPacket();
        ack.ackId = sendAckId;
        target.connection.send([
          ack
        ]);
        print("ACK ${ack.ackId}");
      }

      route._ackGroups.remove(this);
    }
  }
}
