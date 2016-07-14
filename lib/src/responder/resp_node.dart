part of dsa.responder;

/// A node to hold all request handlers, but doesn't deal with the logic the send response back
class RespNode {
  final RespProvider provider;
  final String _path;
  IRespNodeImpl _impl;

  RespNode(this.provider, this._path);

  void attachImpl(IRespNodeImpl impl) {
    if (_impl != null) {
      detachImpl();
    }
    _impl = impl;
    // TODO
  }

  void detachImpl() {
    // TODO
    _impl = null;
  }

  void subscribe(SubscribeHandler handler, IRemoteRequester link) {
    // TODO
  }

  void invoke(InvokeHandler handler, IRemoteRequester link) {
    // TODO
  }

  void list(ListHandler handler, IRemoteRequester link) {
    // TODO
  }

  void setValue(SetValueHandler handler, IRemoteRequester link) {
    // TODO
  }

  void setConfig(SetConfigHandler handler, IRemoteRequester link) {
    // TODO
  }

  void setAttribute(SetAttributeHandler handler, IRemoteRequester link) {
    // TODO
  }

  void removeConfig(RemoveConfigHandler handler, IRemoteRequester link) {
    // TODO
  }

  void removeAttribute(RemoveAttributeHandler handler, IRemoteRequester link) {
    // TODO
  }
}
