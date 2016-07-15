part of dsa.responder;

abstract class Handler implements IDestroyable {
  int rid;

  void processResponse(ResponseFrame frame) {}

  /// return true if the handler is still needed after disconnect
  bool onDisconnect() => false;

  void destroy() {}
}
