import 'package:aoc2020/aoc2020.dart' as aoc2020;

void main(List<String> arguments) async {
  var input = await aoc2020.loadInput(6);
  var sum_counts_1 = 0, sum_counts_2 = 0;
  var any_seen = <String>{};
  var all_seen = <String>{};
  var new_group = true;
  for (var line in input) {
    if (line.isEmpty) {
      sum_counts_1 += any_seen.length;
      sum_counts_2 += all_seen.length;
      any_seen = {};
      all_seen = {};
      new_group = true;
    } else {
      any_seen.addAll(line.split(''));
      if (new_group) {
        all_seen.addAll(line.split(''));
        new_group = false;
      } else {
        for (var c_seen in List.from(all_seen)) {
          if (!line.contains(c_seen)) {
            all_seen.remove(c_seen);
          }
        }
      }
    }
  }
  sum_counts_1 += any_seen.length;
  sum_counts_2 += all_seen.length;
  print('Part 1: ${sum_counts_1}');
  print('Part 2: ${sum_counts_2}');
}
