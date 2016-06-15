part of dsa.broker;

class DefaultControlProvider extends ControlProvider {
  static const String dsaVersion = "2.0.0";

  Broker _broker;
  PrivateKey _key;

  Map<String, Link> _linksByPath = <String, Link>{};
  Map<String, Link> _linksById = <String, Link>{};

  @override
  void registerBroker(Broker broker) {
    _broker = broker;
  }

  @override
  Future authorize(Link link, String auth) async {
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
  Future<Link> getLinkByDsId(String dsId) async {
    return _linksById[dsId];
  }

  @override
  Future<Link> getLinkByPath(String owner) async {
    return _linksByPath[owner];
  }

  @override
  Future<CompletedHandshake> shake(HandshakeRequest request) async {
    Link previousLink = _linksById[request.dsId];
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

    Link link = previousLink != null ? previousLink : new Link(
      _broker,
      dsId: request.dsId,
      path: connPath
    );

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

    _broker.logger.info("DSLink Shaken for ${connPath}");

    return new CompletedHandshake(link, response);
  }
}
