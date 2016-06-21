part of dsa.broker;

class TranslationHandler {
  Map<int, int> _requestTable = <int, int>{};
  Map<int, int> _responseTable = <int, int>{};
  Map<int, String> _requesterDsIdTable = <int, String>{};
  Map<int, String> _responderDsIdTable = <int, String>{};

  int _requestNext = 0;
  int _respondNext = 0;
  int _nextAckId = 0;

  int translateRequest(int rid, [String dsId]) {
    int out = _requestTable[rid];

    if (out == null) {
      out = _incrementRequest();
    }

    if (_responseTable[out] != rid) {
      _responseTable[out] = rid;
    }

    if (dsId != null) {
      _responderDsIdTable[out] = dsId;
    }

    return out;
  }

  int translateResponse(int rid, [String dsId]) {
    int out = _responseTable[rid];

    if (out == null) {
      out = _incrementResponse();
    }

    if (dsId != null) {
      _requesterDsIdTable[out] = dsId;
    }

    return out;
  }

  int _incrementRequest() {
    int id = _requestNext;

    if (_requestNext < 0x7FFFFFFF) {
      ++_requestNext;
    } else {
      id = _requestNext = 0;
    }

    return id;
  }

  int _incrementResponse() {
    int id = _respondNext;

    if (_respondNext < 0x7FFFFFFF) {
      ++_respondNext;
    } else {
      id = _respondNext = 0;
    }

    return id;
  }

  String translateResponseRoute(int rid) {
    return _responderDsIdTable[rid];
  }

  String translateRequestRoute(int rid) {
    return _responderDsIdTable[rid];
  }

  void close(int rid) {
    int r = _requestTable.remove(rid);
    _responseTable.remove(r);
    _responderDsIdTable.remove(r);
  }

  List<DsIdAndRid> getTargetResponsesToClose() {
    var out = [];
    for (int key in _responseTable.keys) {
      int val = _responseTable[key];

      out.add(new DsIdAndRid(translateRequestRoute(val), val));
    }
    return out;
  }

  int getNextAckId() {
    return _nextAckId++;
  }
}

class DsIdAndRid {
  final String dsId;
  final int rid;

  DsIdAndRid(this.dsId, this.rid);
}
