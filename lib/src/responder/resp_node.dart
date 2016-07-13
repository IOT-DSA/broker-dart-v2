part of dsa.responder;

/// A node to hold all request handlers, but doesn't deal with the logic the send response back
class RespNode {
  final RespProvider provider;
  final String _path;
  IRespImpl _impl;

  RespNode(this.provider, this._path);

  void attachImpl(IRespImpl impl) {
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

  SubscribeHandler subscribe(int qos, IRemoteRequester link) {
    // TODO
  }

  InvokeHandler invoke(Map params, IRemoteRequester link) {
    // TODO
  }

  ListHandler list(IRemoteRequester link) {
    // TODO
  }

  SetValueHandler setValue(Object value, IRemoteRequester link) {
    // TODO
  }

  SetConfigHandler setConfig(String key, Object value, IRemoteRequester link) {
    // TODO
  }

  SetAttributeHandler setAttribute(String key, Object value,
      IRemoteRequester link) {
    // TODO
  }

  RemoveConfigHandler removeConfig(String key, IRemoteRequester link) {
    // TODO
  }

  RemoveAttributeHandler removeAttribute(String key, IRemoteRequester link) {
    // TODO
  }
}
