part of dsa.broker;

class Link {
  final Broker broker;
  final String dsId;
  final String path;

  bool isRequester = false;
  bool isResponder = true;

  ConnectionProvider _connection;

  HandshakeRequest handshakeRequest;
  HandshakeResponse handshakeResponse;

  List<int> saltInc = <int>[0, 0, 0];
  List<String> saltBases = new List<String>(3);
  List<String> salts = new List<String>(3);

  bool verifySalt(int type, String hash) {
    if (hash == null) {
      return false;
    }

    if (verifiedNonce != null && verifiedNonce.verifySalt(salts[type], hash)) {
      updateSalt(type);
      return true;
    } else if (tempNonce != null && tempNonce.verifySalt(salts[type], hash)) {
      updateSalt(type);
      nonceChanged();
      return true;
    }
    return false;
  }

  void nonceChanged() {
    verifiedNonce = tempNonce;
    tempNonce = null;
    kick();
  }

  Link(this.broker,
      {this.dsId, this.path, this.isRequester: false, this.isResponder: true}) {
    for (int i = 0; i < 3; ++i) {
      List<int> bytes = new List<int>(12);
      for (int j = 0; j < 12; ++j) {
        bytes[j] = DSRandom.instance.nextUint8();
      }
      saltBases[i] = Base64.encode(bytes);
      updateSalt(i);
    }
  }

  ConnectionProvider get connection => _connection;
  bool get isConnected => _connection != null;

  TranslationHandler translator;

  ECDH verifiedNonce;
  ECDH tempNonce;

  void updateSalt(int type) {
    saltInc[type] += DSRandom.instance.nextUint16();
    salts[type] = '${saltBases[type]}${saltInc[type].toRadixString(16)}';
  }

  void setConnection(ConnectionProvider conn) {
    if (_connection != null) {
      _connection.disconnect();
      _connection = null;
    }

    _connection = conn;
    conn.registerLink(this);
    conn.onDisconnect.then((_) {
      _connection = null;
    });
  }

  void handlePackets(List<DSPacket> packets) {
    broker.route.handle(this, packets);
  }

  void kick() {
    if (isConnected) {
      connection.disconnect();
    }
  }

  @override
  String toString() => "Link(${dsId})";
}
