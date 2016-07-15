part of dsa.broker;

class UserDsLink extends BaseDsLink {
  /// use session string as key
  Map<String, Connection> _connections = {};
}
