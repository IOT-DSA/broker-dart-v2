part of dsa.broker;

class Connection implements IDestroyable {

  RemoteImplProvider implProvider;
  /// rid as key
  Map<int, Handler> _handlers = {};

  /// rid as key
  Map<int, Initiator> _initiators = {};

  RefList<Connection, IAck> _acks;

  Connection() {
    _acks = new RefList<Connection, IAck>(this);
  }


  void disconnected() {
    _handlers.forEach((rid, handler) {
      handler.disconnected();
    });
    _initiators.forEach((rid, initiator) {
      initiator.disconnected();
    });
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
