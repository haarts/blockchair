import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:blockchair/blockchair.dart';

class ContainsKey extends Matcher {
  final Object _key;

  const ContainsKey(this._key);

  @override
  bool matches(item, Map matchState) => item.containsKey(_key);

  @override
  Description describe(Description description) =>
      description.add('contains key ').addDescriptionOf(_key);
}

void main() {
  test('toString()', () {
    expect(
      Blockchair('https://some-url.com', apiKey: 'some-key').toString(),
      'Blockchair: url: https://some-url.com, apiKey: some-key',
    );
  });

  test('timeout property', () {
    var client = Blockchair('', apiKey: '');
    expect(client.timeout, Duration(seconds: 4));

    client.timeout = Duration(seconds: 10);
    expect(client.timeout, Duration(seconds: 10));
  });

  group('stats()', () {
    test('happy path', () async {
      var client = MockClient(
          (request) async => Response(json.encode({"data": 123}), 200));
      expect(
        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .stats(),
        ContainsKey('data'),
      );
    });

    test('throw on timeout', () async {
      var timeout = Duration(milliseconds: 1);
      var inner = MockClient((request) async => Future.delayed(
            timeout + Duration(seconds: 1),
            () => Response(json.encode({"data": 123}), 200),
          ));
      var client =
          Blockchair('https://api.blockchair.com/bitcoin', client: inner)
            ..timeout = timeout;

      expect(
        () => client.stats(),
        throwsA(TypeMatcher<TimeoutException>()),
      );
    });

    test('throw on garbage return', () async {
      var inner = MockClient((request) async => Response('this is not JSON', 200));
      var client = Blockchair('https://api.blockchair.com/bitcoin', client: inner);

      expect(
        () => client.stats(),
        throwsA(TypeMatcher<FormatException>()),
      );
    });

    test('throw on non 2xx response', () async {
      var inner = MockClient((request) async => Response('this is not JSON', 401));
      var client = Blockchair('https://api.blockchair.com/bitcoin', client: inner);

      expect(
        () => client.stats(),
        throwsA(TypeMatcher<NotOkStatusCodeException>()),
      );
    });
  });
}
