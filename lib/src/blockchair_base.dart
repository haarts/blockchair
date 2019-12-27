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
    return null;
  }

  @override
  String toString() => 'Blockchair: url: $_url, apiKey: $_apiKey';
}
