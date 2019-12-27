import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class Blockchair extends BaseClient {
  static const String _statsPath = '/stats';

  Blockchair(String url, {String apiKey, Client client})
      : this._url = Uri.parse(url),
        this._apiKey = apiKey,
        _client = client ?? Client();

  final Uri _url;
  final String _apiKey;
  final Client _client;

  Future<Map<String, dynamic>> stats() async {
    var response = await _client.get('$_url$_statsPath');

    return json.decode(response.body);
  }

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
