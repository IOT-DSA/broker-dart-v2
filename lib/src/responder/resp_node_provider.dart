part of dsa.responder;

class RespProvider {

  IRespImplProvider _implProvider;

  Map<String, RespNode> _nodes = {};

  /// node should already be automatically created
  /// and node should destroy themselves once not in use.
  RespNode getNode(String path) {
    RespNode node = _nodes[path];
    if (node != null) {
      return node;
    }
    node = new RespNode(this, path);
    _nodes[path] = node;
    if (_implProvider != null) {
      node.attachImpl(_implProvider.getImpl(path));
    }
    return node;
  }
}
