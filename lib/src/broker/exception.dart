part of dsa.broker;

class BrokerClientException {
  final String message;

  BrokerClientException(this.message);

  @override
  String toString() => message;
}

class HandshakeException extends BrokerClientException {
  HandshakeException(String message) : super(message);
}
