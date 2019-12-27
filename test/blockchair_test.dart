import 'package:blockchair/blockchair.dart';
import 'package:test/test.dart';

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
    expect(
      await Blockchair('https://api.blockchair.com/bitcoin').stats(),
      ContainsKey('data'),
    );
  });
}
