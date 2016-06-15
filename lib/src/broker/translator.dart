part of dsa.broker;

class TranslationHandler {
  Map<int, int> _requestTable = <int, int>{};
  Map<int, int> _responseTable = <int, int>{};
  Map<int, String> _dsIdTable = <int, String>{};

  int _requestNext = 0;
  int _respondNext = 0;

  int translateRequest(int rid, [String dsId]) {
    int out = _requestTable[rid];

    if (out == null) {
      out = _incrementRequest();
    }

    if (_responseTable[out] != rid) {
      _responseTable[out] = rid;
    }

    if (dsId != null) {
      _dsIdTable[out] = dsId;
    }

    return out;
  }

  int translateResponse(int rid) {
    int out = _responseTable[rid];

    if (out == null) {
      out = _incrementResponse();
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
    return _dsIdTable[rid];
  }

  void close(int rid) {
    int r = _requestTable.remove(rid);
    _responseTable.remove(r);
    _dsIdTable.remove(r);
  }
}
