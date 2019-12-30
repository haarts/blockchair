import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

/// A client to interface with the Blockchair API. When using this client note
/// that three exceptions are to be catched:
/// - TimeoutException
/// - NotOkStatusCodeException
/// - FormatException
class Blockchair extends BaseClient {
  Blockchair(String url, {String apiKey, Client client})
      : _url = Uri.parse(url),
        _coin = Uri.parse(url).path,
        _apiKey = apiKey,
        _client = client ?? Client();

  static const String version = '0.1.0';
  static const String _statsPath = 'stats';
  static const String _blockPath = 'dashboards/block/';
  static const String _blocksPath = 'dashboards/blocks/';
  static const String _statsForKeyPath = '/premium/stats';
  static const String _priorityPath = 'dashboards/transaction/{{}}/priority';
  static const String _transactionPath = 'dashboards/transaction/';
  static const String _transactionsPath = 'dashboards/transactions/';

  final Uri _url;
  final String _coin;
  final String _apiKey;
  final Client _client;

  /// Timeout a request after this many seconds.
  Duration timeout = const Duration(seconds: 4);

  /// Returns a Map with some basic data about the chain.
  Future<Map<String, dynamic>> stats() async {
    var response = await _get(_url.replace(path: '$_coin$_statsPath'));

    return json.decode(response.body);
  }

  /// Returns data about the configured api key.
  Future<Map<String, dynamic>> statsForKey() async {
    var response = await _get(_url.replace(path: _statsForKeyPath));

    return json.decode(response.body);
  }

  /// Returns the priority of a certain transaction in the mempool.
  Future<Map<String, dynamic>> priority(String txHash) async {
    var response = await _get(_url.replace(
        path:
            '$_coin${_priorityPath.replaceFirst(RegExp('\{\{\}\}'), txHash)}'));

    return json.decode(response.body);
  }

  /// Returns information on a specific transaction.
  Future<Map<String, dynamic>> transaction(String txHash) async {
    var response =
        await _get(_url.replace(path: '$_coin$_transactionPath$txHash'));

    return json.decode(response.body);
  }

  /// Returns information on a set of maximum 10 transactions. Note that this
  /// call is significantly cheaper in API credits than 10 seperate
  /// `transaction` calls.
  Future<Map<String, dynamic>> transactions(List<String> txHashes) async {
    if (txHashes.length > 10) {
      throw ClientException(
          'List argument too long. Is ${txHashes.length}, should be smaller or equal than 10');
    }

    var response =
        await _get(_url.replace(path: '$_coin$_transactionsPath${txHashes.join(',')}'));

    return json.decode(response.body);
  }

  // Returns data on a specific block.
  Future<Map<String, dynamic>> block(blockIdentifier) async {
    var response =
        await _get(_url.replace(path: '$_coin$_blockPath$blockIdentifier'));

    return json.decode(response.body);
  }

  /// Returns information on a set of maximum 10 blocks. Note that this
  /// call is significantly cheaper in API credits than 10 seperate
  /// `block` calls.
  Future<Map<String, dynamic>> blocks(List blockIdentifiers) async {
    if (blockIdentifiers.length > 10) {
      throw ClientException(
          'List argument too long. Is ${blockIdentifiers.length}, should be smaller or equal than 10');
    }

    var response = await _get(
        _url.replace(path: '$_coin$_blocksPath${blockIdentifiers.join(',')}'));

    return json.decode(response.body);
  }

  Future<Response> _get(Uri url) async {
    Map<String, dynamic> queryParameters = Map.from(url.queryParameters);
    if (_apiKey != null) {
      queryParameters['key'] = _apiKey;
    }

    var response = await _client
        .get(url.replace(queryParameters: queryParameters))
        .timeout(timeout);
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
  void close() {
    _client.close();
  }

  @override
  String toString() => 'Blockchair: url: $_url, apiKey: $_apiKey';
}

class NotOkStatusCodeException implements Exception {
  NotOkStatusCodeException(this.url, this.statusCode);

  final Uri url;
  final int statusCode;

  @override
  String toString() =>
      'NotOkStatusCodeException: url = $url, statusCode = $statusCode';
}
