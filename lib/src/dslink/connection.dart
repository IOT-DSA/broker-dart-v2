part of dsa.broker;

class Connection {
  /// rid as key
  Map<int, Handler> _handlers = {};
  /// rid as key
  Map<int, Initiator> _initiators = {};

}
