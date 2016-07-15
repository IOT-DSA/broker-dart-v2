part of dsa.broker;

class DefaultRouteProvider extends RouteProvider {
  static const List<String> linkPoints = const <String>[
    "/downstream/",
    "/upstream/",
    "/sys/quarantine/"
  ];

  Broker _broker;

  @override
  void registerBroker(Broker broker) {
    _broker = broker;
  }

  @override
  Future init() async {}

  @override
  handle(Link sourceLink, List<DSPacket> packets) async {
    var deliverQueue = <Link, List<DSPacket>>{};

    pub(Link link, DSPacket pkt) {
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
        var ack = new DSAckPacket();
        ack.ackId = packet.ackId;

        pub(sourceLink, ack);
      } else if (packet is DSAckPacket) {} else if (packet is DSRequestPacket &&
          sourceLink.isRequester) {
        var path = packet.path;
        var route = describe(path);
        var link = await _broker.control.getLinkByPath(route.owner);

        if (link == null) {
          var resp = new DSResponsePacket();
          resp.rid = packet.rid;
          resp.method = DSPacketMethod.close;
          resp.mode = DSPacketResponseMode.closed;
          resp.setPayload({"type": "disconnected"});
          pub(sourceLink, resp);
        } else {
          packet.path = path;
          pub(link, packet);
        }
      } else if (packet is DSResponsePacket && sourceLink.isResponder) {
        var link = await _broker.control.getLinkByDsId(
            sourceLink.translator.translateResponseRoute(packet.rid));

        if (link == null) {
          var req = new DSRequestPacket();
          req.rid = packet.rid;
          req.method = DSPacketMethod.close;
          req.setPayload({"type": "disconnected"});
          pub(sourceLink, req);
        } else {
          pub(link, packet);
        }
      }
    }

    if (_broker.logger.isLoggable(Level.FINEST)) {
      _broker.logger.finest("Deliver: $deliverQueue");
    }

    for (Link link in deliverQueue.keys) {
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
  Future stop() async {}
}
