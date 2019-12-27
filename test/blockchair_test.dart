import 'package:blockchair/blockchair.dart';
import 'package:test/test.dart';

void main() {
  test('toString()', () {
    expect(
      Blockchair('https://some-url.com', 'some-key').toString(),
      'Blockchair: url: https://some-url.com, apiKey: some-key',
    );
  });
}
