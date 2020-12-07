import 'package:aoc2020/aoc2020.dart' as aoc2020;

void day6() async {
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

void day7() async {
  var input = await aoc2020.loadInput(7);
  var can_contain = <String, Map<String, int>>{};
  for (var line in input) {
    if (line.isEmpty) {
      continue;
    }
    line = line.replaceAll('bags', '').replaceAll('bag', '');
    var part = line.split(' contain ');
    var fp = part[0].trim();
    var sp = part[1].replaceAll('.', '');
    if (sp.contains('no other')) {
      can_contain[fp] = Map();
    } else {
      can_contain[fp] = Map();
      for (var color in sp.split(',')) {
        var r = RegExp(r'(\d+)\s(\D+)');
        var matches = r.allMatches(color);
        var number = int.parse(matches.elementAt(0).group(1));
        var color_name = matches.elementAt(0).group(2).trim();
        can_contain[fp][color_name] = number;
      }
    }
  }
  bool canReach(String from, String to) {
    if (can_contain[from].containsKey(to)) {
      return true;
    }
    for (var reach in can_contain[from].keys) {
      if (canReach(reach, to)) {
        return true;
      }
    }
    return false;
  }

  var sum = 0;
  for (var color in can_contain.keys) {
    sum += canReach(color, 'shiny gold') ? 1 : 0;
  }

  int dfs(String from) {
    if (can_contain[from].isEmpty) {
      return 1;
    }
    var sum_so_far = 1;
    for (var key in can_contain[from].keys) {
      sum_so_far += can_contain[from][key] * dfs(key);
    }
    return sum_so_far;
  }

  var sum2 = dfs('shiny gold') - 1; // Don't count the shiny gold bag itself.

  print('Part 1: {$sum}');
  print('Part 1: {$sum2}');
}

void main(List<String> arguments) async {
  await day7();
}
