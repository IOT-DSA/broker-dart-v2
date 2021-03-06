part of dsa.broker;

class Connection implements IDestroyable {
  RemoteImplProvider implProvider;

  /// rid as key
  Map<int, Handler> _handlers = {};

  /// rid as key
  Map<int, Initiator> _initiators = {};

  Map<int, AckIdHolder> _ackMap = {};
  RefList<Connection, IAck> _acks;

  Connection() {
    _acks = new RefList<Connection, IAck>(this);
  }

  void requestFrameReceived(RequestFrame frame) {

  }

  void responseFrameReceived(ResponseFrame frame) {

  }

  void ackReceived(int ackId) {
    if (_ackMap.containsKey(ackId)) {
      int ts = (new DateTime.now()).millisecondsSinceEpoch;
      AckIdHolder ackHolder = _ackMap[ackId];

      _acks.firstWhere((ref) {
        ref.remove();
        if (ref.value == ackHolder) {
          return true;
        }
        ref.value.ack(ts);
        return false;
      });
    }
  }

  void onDisconnect() {
    Map<int, Handler> activeHandlers = {};
    _handlers.forEach((rid, handler) {
      if (handler.onDisconnect()) {
        activeHandlers[rid] = handler;
      }
    });
    _handlers = activeHandlers;

    _initiators.forEach((rid, initiator) {
      initiator.destroy();
    });
    _initiators.clear();
  }

  void destroy() {
    _handlers.forEach((rid, handler) {
      handler.destroy();
    });
    _initiators.forEach((rid, initiator) {
      initiator.destroy();
    });
    implProvider.destroy();
  }
}
