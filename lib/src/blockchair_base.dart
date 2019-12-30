import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class Blockchair extends BaseClient {
  Blockchair(String url, {String apiKey, Client client})
      : _url = Uri.parse(url),
        _apiKey = apiKey,
        _client = client ?? Client();

  static const String version = '0.1.0';
  static const String _statsPath = '/stats';
  static const String _blockPath = '/dashboards/block/';
  static const String _blocksPath = '/dashboards/blocks/';
  static const String _statsForKeyPath = '/premium/stats';

  final Uri _url;
  final String _apiKey;
  final Client _client;

  Duration timeout = const Duration(seconds: 4);

  Future<Map<String, dynamic>> stats() async {
    var response = await _get('$_url$_statsPath');

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> statsForKey() async {
    var response = await _get(_url.replace(path: _statsForKeyPath, queryParameters: {'key': _apiKey}).toString());

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> block(blockIdentifier) async {
    var response = await _get('$_url$_blockPath$blockIdentifier');

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> blocks(List blockIdentifiers) async {
    if (blockIdentifiers.length > 10) {
      throw ClientException('');
    }

    var response = await _get('$_url$_blocksPath${blockIdentifiers.join(',')}');

    return json.decode(response.body);
  }

  Future<Response> _get(String url) async {
    var response = await _client.get(url).timeout(timeout);
    if (!(response.statusCode >= 200 && response.statusCode < 400)) {
      throw NotOkStatusCodeException(url, response.statusCode);
    }

		return response;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers[HttpHeaders.userAgentHeader] =
        'Blockchair v$version - Dart (https://pub.dev/packages/blockchair)';
    request.headers[HttpHeaders.contentTypeHeader] = 'application/json';

    return _client.send(request);
  }

  @override
  String toString() => 'Blockchair: url: $_url, apiKey: $_apiKey';
}

class NotOkStatusCodeException implements Exception {
  NotOkStatusCodeException(this.url, this.statusCode);

  final String url;
  final int statusCode;

  String toString() => 'NotOkStatusCodeException: url = $url, statusCode = $statusCode';
}
