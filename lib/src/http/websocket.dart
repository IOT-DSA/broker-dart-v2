part of dsa.broker;

class WebSocketProvider extends ConnectionProvider {
  final WebSocket socket;

  Link _link;

  WebSocketProvider(this.socket);

  @override
  void registerLink(Link link) {
    _link = link;

    var reader = new DSPacketReader();

    socket.listen((data) {
      if (data is Uint8List && data.lengthInBytes != 0) {
        _link.handlePackets(reader.read(data as Uint8List));
      }
    });

    _pingTimer = new Timer.periodic(const Duration(seconds: 30), (_) {
      if (socket.readyState == WebSocket.CLOSED) {
        _pingTimer.cancel();
      } else {
        socket.add(const <int>[]);
      }
    });

    socket.add(const <int>[]);
  }

  Timer _pingTimer;

  @override
  void send(List<DSPacket> packets) {
    var writer = new DSPacketWriter();

    for (DSPacket pkt in packets) {
      pkt.writeTo(writer);
    }
    var msg = new DSMsgPacket();
    msg.ackId = _ackId++;
    msg.writeTo(writer);
    socket.add(writer.done());
  }

  int _ackId = 0;

  @override
  void disconnect() {
    socket.close();
  }

  @override
  Future get onDisconnect => socket.done.then((_) {
        _pingTimer.cancel();
      });
}
