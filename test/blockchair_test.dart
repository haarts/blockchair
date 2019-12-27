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

  test('stats()', () async {
    var client = MockClient(
        (response) async => Response(json.encode({"data": 123}), 200));
    expect(
      await Blockchair('https://api.blockchair.com/bitcoin', client: client)
          .stats(),
      ContainsKey('data'),
    );
  });
}
