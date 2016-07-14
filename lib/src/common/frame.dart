part of dsa.common;

class RequestFrame {
  int type;
  int rid;
  int updateId;
  int clusterId;
  String path;
  Uint8List payload;
}

class ResponseFrame {
  int type;
  int rid;
  int updateId;
  int clusterId;
  int status;
  Uint8List payload;
}
