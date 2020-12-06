import 'dart:io';

Future<List<String>> loadInput(int day) async {
  return File('in/${day}.txt').readAsLines();
}
