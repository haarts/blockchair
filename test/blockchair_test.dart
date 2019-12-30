import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'package:blockchair/blockchair.dart';

class ContainsKey extends Matcher {
  const ContainsKey(this._key);

  final Object _key;

  @override
  bool matches(item, Map matchState) => item.containsKey(_key);

  @override
  Description describe(Description description) =>
      description.add('contains key ').addDescriptionOf(_key);
}

void main() {
  dynamic client;

  tearDown(() => client?.close());

  test('toString()', () {
    expect(
      Blockchair('https://some-url.com', apiKey: 'some-key').toString(),
      'Blockchair: url: https://some-url.com, apiKey: some-key',
    );
  });

  test('timeout property', () {
    client = Blockchair('', apiKey: '');
    expect(client.timeout, Duration(seconds: 4));

    client.timeout = Duration(seconds: 10);
    expect(client.timeout, Duration(seconds: 10));
  });

  group('stats()', () {
    test('happy path', () async {
      client = MockClient(
          (request) async => Response(json.encode({"data": 123}), 200));
      expect(
        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .stats(),
        ContainsKey('data'),
      );
    });

    group('standard exceptions', () {
      test('throw on timeout', () async {
        client = timingOut();

        expect(
          () => client.stats(),
          throwsA(TypeMatcher<TimeoutException>()),
        );
      });

      test('throw on garbage return', () async {
        client = garbageReturn();

        expect(
          () => client.stats(),
          throwsA(TypeMatcher<FormatException>()),
        );
      });

      test('throw on non 2xx response', () async {
        client = notOk();

        expect(
          () => client.stats(),
          throwsA(TypeMatcher<NotOkStatusCodeException>()),
        );
      });
    });
  });

  group('block()', () {
    group('happy path', () {
      test('with block height', () async {
        client = MockClient((request) async {
          expect(request.url.pathSegments.last, '1');
          return Response(json.encode({"data": 123}), 200);
        });
        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .block(1);
      });

      test('with block hash', () async {
        client = MockClient((request) async {
          expect(request.url.pathSegments.last, 'some-hash');
          return Response(json.encode({"data": 123}), 200);
        });
        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .block('some-hash');
      });
    });

    group('standard exceptions', () {
      test('throw on timeout', () async {
        client = timingOut();

        expect(() => client.block(1), throwsA(TypeMatcher<TimeoutException>()));
      });

      test('throw on garbage return', () async {
        client = garbageReturn();

        expect(() => client.block(1), throwsA(TypeMatcher<FormatException>()));
      });

      test('throw on non 2xx response', () async {
        client = notOk();

        expect(() => client.block(1),
            throwsA(TypeMatcher<NotOkStatusCodeException>()));
      });
    });
  });

  group('blocks()', () {
    group('happy path', () {
      test('with block heights', () async {
        client = MockClient((request) async {
          expect(request.url.pathSegments.last, '1,2');
          return Response(json.encode({"data": 123}), 200);
        });
        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .blocks([1, 2]);
      });

      test('with block hashes', () async {
        client = MockClient((request) async {
          expect(request.url.pathSegments.last, 'some-hash,some-other-hash');
          return Response(json.encode({"data": 123}), 200);
        });

        await Blockchair('https://api.blockchair.com/bitcoin', client: client)
            .blocks(['some-hash', 'some-other-hash']);
      });
    });

    test('maximize list to 10 items', () async {
      expect(() => Blockchair('').blocks([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
          throwsA(TypeMatcher<ClientException>()));
    });

    group('standard exceptions', () {
      test('throw on timeout', () async {
        client = timingOut();

        expect(
            () => client.blocks([]), throwsA(TypeMatcher<TimeoutException>()));
      });

      test('throw on garbage return', () async {
        client = garbageReturn();

        expect(
            () => client.blocks([]), throwsA(TypeMatcher<FormatException>()));
      });

      test('throw on non 2xx response', () async {
        client = notOk();

        expect(() => client.blocks([]),
            throwsA(TypeMatcher<NotOkStatusCodeException>()));
      });
    });
  });

  test('statsForKey()', () async {
    client = Blockchair(
      '',
      apiKey: 'some-key',
      client: MockClient((request) async {
        expect(request.url.path, matches('premium'));
        expect(request.url.queryParameters, ContainsKey('key'));
        return Response('{}', 200);
      }),
    );

    await client.statsForKey();
  });

  test('priority()', () async {
    var inner = MockClient((request) async {
      expect(request.url.path,
          '/bitcoin/dashboards/transaction/some-hash/priority');
      expect(request.url.queryParameters, ContainsKey('key'));
      return Response('{}', 200);
    });
    client = Blockchair(
      'https://api.blockchair.com/bitcoin/',
      apiKey: 'some-key',
      client: inner,
    );

    await client.priority('some-hash');
  });

  test('transaction()', () async {
    var inner = MockClient((request) async {
      expect(request.url.path, '/bitcoin/dashboards/transaction/some-hash');
      return Response('{}', 200);
    });
    client = Blockchair(
      'https://api.blockchair.com/bitcoin/',
      client: inner,
    );

    await client.transaction('some-hash');
  });

  group('transactions()', () {
    test('happy path', () async {
      var inner = MockClient((request) async {
        expect(request.url.path,
            '/bitcoin/dashboards/transactions/some-hash,some-other-hash');
        return Response('{}', 200);
      });
      client = Blockchair(
        'https://api.blockchair.com/bitcoin/',
        client: inner,
      );

      await client.transactions(['some-hash', 'some-other-hash']);
    });

    test('maximize list to 10 items', () async {
      expect(
          () => Blockchair('').transactions(
              ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11']),
          throwsA(TypeMatcher<ClientException>()));
    });
  });
}

Blockchair timingOut() {
  var timeout = Duration(milliseconds: 1);
  var inner = MockClient((request) async => Future.delayed(
        timeout + Duration(seconds: 1),
        () => Response(json.encode({"data": 123}), 200),
      ));
  return Blockchair('https://some-url.com', client: inner)..timeout = timeout;
}

Blockchair garbageReturn() {
  var inner = MockClient((request) async => Response('this is not JSON', 200));
  return Blockchair('https://some-url.com', client: inner);
}

Blockchair notOk() {
  var inner = MockClient((request) async => Response('{}', 401));
  return Blockchair('https://some-url.com', client: inner);
}
