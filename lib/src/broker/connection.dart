part of dsa.broker;

abstract class ConnectionProvider {
  void registerLink(DSLink link);
  void send(List<DSPacket> packets);
  void disconnect();

  Future get onDisconnect;
}
