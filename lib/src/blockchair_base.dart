// import 'dart:io';

import 'package:http/http.dart';

class Blockchair extends BaseClient {
  Blockchair(String url, this._apiKey)
      : this._url = Uri.parse(url),
        _client = Client();

  final Uri _url;
  final String _apiKey;
  final Client _client;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers[HttpHeaders.userAgentHeader] =
        'Blockchair - Dart (pub.dev/packages/blockchair)';
    request.headers[HttpHeaders.contentTypeHeader] = 'application/json';

    return _client.send(request);
  }

  @override
  String toString() => 'Blockchair: url: $_url, apiKey: $_apiKey';
}
