# Blockbook library

[![pub package](https://img.shields.io/pub/v/blockchair.svg)](https://pub.dev/packages/blockchair)
[![CircleCI](https://circleci.com/gh/inapay/blockchair.svg?style=svg)](https://circleci.com/gh/inapay/blockchair)

A library for communicating with the [Blockchair API]. Some calls are missing.

## Usage

A simple usage example:

```dart
import 'package:blockchair/blockchair.dart';

main() async {
  var client = new Blockchair('https://api.blockchair.com/bitcoin/', apiKey: 'some key');
  print(await client.stats());
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/inapay/blockchair/issues
[Blockchair API]: https://blockchair.com/api/docs
