part of dsa.broker;

abstract class ConnectionProvider {
  void registerLink(Link link);
  void send(List<DSPacket> packets);
  void disconnect();

  Future get onDisconnect;
}
