part of dsa.common;

abstract class IAck {
  void ack(int ts);
}

class AckIdHolder extends IAck {
  final int msgId;

  AckIdHolder(this.msgId);

  void ack(int ts) {}
}
