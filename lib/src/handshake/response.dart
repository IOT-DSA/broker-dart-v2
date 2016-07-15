part of dsa.broker;

class CompletedHandshake {
  final Link link;
  final HandshakeResponse response;

  CompletedHandshake(this.link, this.response);
}

class HandshakeResponse {
  final String dsId;
  final String publicKey;
  final String wsUri;
  final String tempKey;
  final String salt;
  final String saltS;
  final String saltL;
  final String path;
  final String version;

  final Link link;

  HandshakeResponse(
      {this.dsId,
      this.publicKey,
      this.wsUri,
      this.tempKey,
      this.salt,
      this.saltL,
      this.saltS,
      this.path,
      this.version,
      this.link});

  Map<String, dynamic> encode([Map<String, dynamic> addons]) {
    var out = <String, dynamic>{
      "id": dsId,
      "publicKey": publicKey,
      "wsUri": wsUri,
      "tempKey": tempKey,
      "salt": salt,
      "saltL": saltL,
      "saltS": saltS,
      "path": path,
      "version": version
    };

    if (addons != null) {
      out.addAll(addons);
    }

    return out;
  }
}
