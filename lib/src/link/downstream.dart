part of dsa.broker.link;

class DownstreamNode extends SimpleNode {
  DownstreamNode(String path) : super(path);

  void addLink(DSLink link) {
    var name = link.path.split("/").last;
    var node = new VirtualDownstreamLinkNode(link.path);
    provider.setNode(node.path, node);
    addChild(name, node);
  }

  void removeLink(DSLink link) {
    var name = link.path.split("/").last;
    removeChild(name);
  }
}

class VirtualDownstreamLinkNode extends SimpleNode {
  VirtualDownstreamLinkNode(String path) : super(path) {
    configs.addAll({
      r"$is": "dsa/link"
    });
  }
}
