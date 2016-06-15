part of dsa.broker;

class HandshakeRequest {
  final String version;
  final bool isRequester;
  final bool isResponder;
  final Map<String, dynamic> linkData;
  final String dsId;
  final String token;
  final String publicKey;
  final Map<String, dynamic> json;
  final String session;

  HandshakeRequest({
    this.version,
    this.isRequester,
    this.isResponder,
    this.linkData,
    this.dsId,
    this.token,
    this.publicKey,
    this.json,
    this.session
  });

  factory HandshakeRequest.decode(Map<String, dynamic> input, {
    String token,
    String dsId,
    String session
  }) {
    String version = input["version"];
    bool isRequester = input["isRequester"] == true;
    bool isResponder = input["isResponder"] == true;

    Map<String, dynamic> linkData = input["linkData"];
    if (linkData == null) {
      linkData = const <String, dynamic>{};
    }

    String token = input["token"];
    String publicKey = input["publicKey"];

    return new HandshakeRequest(
      version: version,
      isRequester: isRequester,
      isResponder: isResponder,
      linkData: linkData,
      dsId: dsId,
      token: token,
      publicKey: publicKey,
      json: input
    );
  }
}
