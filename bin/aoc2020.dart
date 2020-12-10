import 'dart:math';
import 'package:quiver/iterables.dart' as quiver;

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

void day8() async {
  var input = await aoc2020.loadInput(8);
  var prog = input.map((line) => line.split(' ')).toList();

  int itCompletes(prog, zeroOnError) {
    var acc = 0;
    var idx = 0;
    var visited = Set();
    while (true) {
      if (idx == prog.length) {
        return acc;
      }
      if (visited.contains(idx)) {
        if (zeroOnError) {
          return 0;
        } else {
          return acc;
        }
      }
      var sep = prog[idx];
      var op = sep[0];
      var val = int.parse(sep[1]);
      visited.add(idx);
      if (op == 'acc') {
        acc += val;
        idx += 1;
      } else if (op == 'nop') {
        idx += 1;
      } else if (op == 'jmp') {
        idx += val;
      }
    }
  }

  print('Part 1: ${itCompletes(prog, false)}');

  for (var inst in prog) {
    var p_inst = inst[0];
    if (p_inst == 'jmp') {
      inst[0] = 'nop';
    } else if (p_inst == 'nop') {
      inst[0] = 'jmp';
    }
    var res = itCompletes(prog, true);
    if (res != 0) {
      print('Part 2: ${res}');
      break;
    }
    inst[0] = p_inst;
  }
}

void day9() async {
  final input =
      (await aoc2020.loadInput(9)).map((s_num) => int.parse(s_num)).toList();
  const PREVIOUS = 25;
  var sum_to;
  for (var idx = PREVIOUS; idx < input.length; idx++) {
    sum_to = input[idx];
    var can_i_make = false;
    for (var sub_idx = idx - PREVIOUS; sub_idx < idx - 1; sub_idx++) {
      for (var sub_idx_2 = sub_idx + 1; sub_idx_2 < idx; sub_idx_2++) {
        if (input[sub_idx_2] + input[sub_idx] == sum_to) {
          can_i_make = true;
        }
      }
    }
    if (!can_i_make) {
      print('Part1: ${sum_to}');
      break;
    }
  }
  for (var idx = 0; idx < input.length - 1; idx++) {
    var idx2 = idx + 1;
    var sum_so_far = input[idx] + input[idx2];
    while (idx2 < input.length && sum_so_far < sum_to) {
      idx2 += 1;
      sum_so_far += input[idx2];
    }
    if (sum_so_far == sum_to) {
      var range = input.sublist(idx, idx2);
      var res = range.reduce(min) + range.reduce(max);
      print('Part2: ${res}');
      break;
    }
  }
}

void day10() async {
  final input =
      (await aoc2020.loadInput(10)).map((s_num) => int.parse(s_num)).toList();

  final device_rating = input.reduce(max) + 3;
  input.addAll([0, device_rating]);
  input.sort((a, b) => a.compareTo(b));
  var trimmedList = List<int>.from(input);
  var shiftedList = List<int>.from(input);
  shiftedList.remove(0);
  trimmedList.removeLast();
  var jumps =
      quiver.zip([trimmedList, shiftedList]).map((x) => x[1] - x[0]).toList();
  int count(l, n) {
    return l.where((e) => e == n).toList().length;
  }

  var sol1 = count(jumps, 1) * count(jumps, 3);
  print('Part 1: ${sol1}');

  var ways = List.filled(input.length, 0);
  ways[0] = 1;
  for (var i = 0; i < input.length - 1; i++) {
    for (var j = i + 1; j < input.length; j++) {
      if ((input[j] - input[i]) > 3) {
        break;
      }
      ways[j] += ways[i];
    }
  }
  print('Part 2: ${ways.reduce(max)}');
}

void main(List<String> arguments) async {
  await day10();
}
