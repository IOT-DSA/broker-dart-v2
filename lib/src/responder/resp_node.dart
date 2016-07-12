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

  BaseHandler setValue(Object value, IRemoteRequester link) {
    // TODO
  }

  BaseHandler setConfig(String key, Object value, IRemoteRequester link) {
    // TODO
  }

  BaseHandler setAttribute(String key, Object value, IRemoteRequester link) {
    // TODO
  }

  BaseHandler removeConfig(String key, IRemoteRequester link) {
    // TODO
  }

  BaseHandler removeAttribute(String key, IRemoteRequester link) {
    // TODO
  }
}
