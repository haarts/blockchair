import 'package:blockchair/blockchair.dart';

// ignore_for_file: avoid_print
main() async {
  var client = Blockchair('https://api.blockchair.com/bitcoin/');
  print(await client.stats());

  print(await client.blocks([1, 2]));

  client.close();
}
