part of dsa.responder;

class InvokeHandler extends Handler {
  /// raw payload of an action
  /// should set to null once consumed
  RawBytes payload;
}
