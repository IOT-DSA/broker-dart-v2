part of dsa.broker.link;

class UpstreamNode extends SimpleNode {
  UpstreamNode(String path) : super(path);

  void addLink(DSLink link) {
    var name = link.path.split("/").last;
    var node = new VirtualUpstreamLinkNode(link.path);
    provider.setNode(node.path, node);
    addChild(name, node);
  }

  void removeLink(DSLink link) {
    var name = link.path.split("/").last;
    removeChild(name);
  }
}

class VirtualUpstreamLinkNode extends SimpleNode {
  VirtualUpstreamLinkNode(String path) : super(path) {
    configs.addAll({
      r"$is": "dsa/link"
    });
  }
}
