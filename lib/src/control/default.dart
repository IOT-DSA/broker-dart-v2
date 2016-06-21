part of dsa.broker;

class DefaultControlProvider extends ControlProvider {
  static const String dsaVersion = "2.0.0";

  Broker _broker;
  PrivateKey _key;

  Map<String, DSLink> _linksByPath = <String, DSLink>{};
  Map<String, DSLink> _linksById = <String, DSLink>{};

  @override
  void registerBroker(Broker broker) {
    _broker = broker;

    _broker.taskLoop.register("save.conns", () async {
      var out = <String, Map<String, dynamic>>{};

      for (DSLink link in _linksById.values) {
        out[link.dsId] = <String, dynamic>{
          "dsId": link.dsId,
          "path": link.path
        };

        for (BrokerEventListener listener in _listeners) {
          listener.handleNewLink(link);
        }
      }

      await _broker.storage.store("conns", out);
    });
  }

  @override
  Future init() async {
    await _loadConns();
  }

  @override
  Future authorize(DSLink link, String auth) async {
    if (!link.verifySalt(0, auth)) {
      throw new BrokerClientException(
        "Failed to authorize link: Invalid auth."
      );
    }
  }

  @override
  Future<PrivateKey> getBrokerKey() async {
    if (_key == null) {
      _key = await PrivateKey.generate();
    }
    return _key;
  }

  @override
  Future<DSLink> getLinkByDsId(String dsId) async {
    return _linksById[dsId];
  }

  @override
  Future<DSLink> getLinkByPath(String owner) async {
    return _linksByPath[owner];
  }

  @override
  Future<CompletedHandshake> shake(HandshakeRequest request) async {
    DSLink previousLink = _linksById[request.dsId];

    ECDH lastNonce = previousLink != null ? previousLink.verifiedNonce : null;

    Uint8List publicKeyBytes = Base64.decode(request.publicKey);

    if (publicKeyBytes == null) {
      throw new BrokerClientException("Invalid Public Key.");
    }

    String folderPath = "/downstream/";
    String connPath;

    var dsId = request.dsId;

    int i = 43;
    if (dsId.length == 43) i = 42;
    for (; i >= 0; --i) {
      connPath = "$folderPath${dsId.substring(0, dsId.length - i)}";
      if (i == 43 && connPath.length > 8 && connPath.endsWith("-")) {
        // remove the last - in the name;
        connPath = connPath.substring(0, connPath.length - 1);
      }

      if (!_linksByPath.containsKey(connPath)) {
        break;
      }
    }

    DSLink link = previousLink != null ? previousLink : new DSLink(
      _broker,
      dsId: request.dsId,
      path: connPath
    );

    link.isRequester = request.isRequester;
    link.isResponder = request.isRequester;

    _linksById[link.dsId] = link;
    _linksByPath[link.path] = link;

    PublicKey publicKey = new PublicKey.fromBytes(publicKeyBytes);
    link.tempNonce = await ECDH.assign(publicKey, lastNonce);
    var brokerKey = await getBrokerKey();
    var brokerDsId = brokerKey.publicKey.getDsId("broker-dsa");
    var brokerPublicKey = brokerKey.publicKey.qBase64;
    var response = new HandshakeResponse(
      dsId: brokerDsId,
      publicKey: brokerPublicKey,
      wsUri: "/ws",
      version: dsaVersion,
      tempKey: link.tempNonce.encodedPublicKey,
      salt: link.salts[0],
      saltL: link.salts[1],
      saltS: link.salts[2],
      path: link.path
    );

    _broker.logger.info("DSLink shaken for ${connPath}");

    _broker.taskLoop.schedule("save.conns");

    if (previousLink != link) {
      for (BrokerEventListener listener in _listeners) {
        listener.handleNewLink(link);
      }
    }

    return new CompletedHandshake(link, response);
  }

  @override
  Future clearConns() async {
    for (DSLink link in _linksByPath.values) {
      if (!link.isConnected) {
        _linksById.remove(link.dsId);
        _linksByPath.remove(link.path);
      }
    }

    _broker.taskLoop.schedule("save.conns");
  }

  @override
  Stream<DSLink> getConnectedLinks() async* {
    for (DSLink link in _linksById.values) {
      if (link.isConnected) {
        yield link;
      }
    }
  }

  @override
  Stream<DSLink> getKnownLinks() async* {
    for (DSLink link in _linksById.values) {
      yield link;
    }
  }

  Future _loadConns() async {
    var conns = await _broker.storage.retrieve("conns");

    if (conns is Map) {
      for (var key in conns.keys) {
        var map = conns[key];

        if (map["dsId"] is String && map["path"] is String) {
          String id = map["dsId"];
          String path = map["path"];

          _linksById[map["dsId"]] = new DSLink(
            _broker,
            dsId: id,
            path: path
          );
        }
      }
    }
  }

  @override
  Future stop() async {
    for (DSLink link in _linksById.values) {
      link.kick();
    }

    _linksById.clear();
    _linksByPath.clear();
    _broker.taskLoop.unregister("save.conns");
  }

  @override
  void addEventListener(BrokerEventListener listener) {
    _listeners.add(listener);
  }

  List<BrokerEventListener> _listeners = <BrokerEventListener>[];

  @override
  void registerBrokerLink(BrokerLink brokerLink) {
    _linksByPath["/"] = brokerLink;
    _linksById[brokerLink.dsId] = brokerLink;
  }
}
