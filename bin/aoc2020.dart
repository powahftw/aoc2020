import 'dart:math';
import 'package:quiver/iterables.dart' as quiver;
import 'package:dart_numerics/dart_numerics.dart' as numerics;

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

void day11() async {
  final input =
      (await aoc2020.loadInput(11)).map((line) => line.split('')).toList();
  var max_r = input.length;
  var max_c = input[0].length;
  const dirs = [
    [0, 1],
    [1, 0],
    [1, 1],
    [-1, 0],
    [0, -1],
    [-1, -1],
    [1, -1],
    [-1, 1]
  ];
  int get_nearby(List<List<String>> inp, int r, int c) {
    var res = 0;
    for (var d in dirs) {
      var dx = d[0];
      var dy = d[1];
      var x = c + dx;
      var y = r + dy;
      if (x < 0 || x >= max_c) {
        continue;
      }
      if (y < 0 || y >= max_r) {
        continue;
      }
      res += (inp[y][x] == '#') ? 1 : 0;
    }
    return res;
  }

  int get_visible(List<List<String>> inp, int r, int c) {
    var occ = 0;
    for (var d in dirs) {
      var dx = d[0];
      var dy = d[1];
      var new_r = r + dy;
      var new_c = c + dx;
      while (new_r >= 0 && new_r < max_r && new_c >= 0 && new_c < max_c) {
        if (inp[new_r][new_c] == '#') {
          occ += 1;
          break;
        } else if (inp[new_r][new_c] == 'L') {
          break;
        }
        new_r += dy;
        new_c += dx;
      }
    }
    return occ;
  }

  void solve(int part) {
    var changed = true;
    var prev_state = input;
    while (changed) {
      changed = false;
      var new_state = List.generate(max_r, (_) => List<String>(max_c));
      for (var idx_r = 0; idx_r < max_r; idx_r++) {
        for (var idx_c = 0; idx_c < max_c; idx_c++) {
          var prev_cell = prev_state[idx_r][idx_c];
          var occupied_nearby = (part == 1)
              ? get_nearby(prev_state, idx_r, idx_c)
              : get_visible(prev_state, idx_r, idx_c);
          var too_crowded = (part == 1) ? 3 : 4;
          if (prev_cell == 'L' && occupied_nearby == 0) {
            new_state[idx_r][idx_c] = '#';
            changed = true;
          } else if (prev_cell == '#' && occupied_nearby > too_crowded) {
            new_state[idx_r][idx_c] = 'L';
            changed = true;
          } else {
            new_state[idx_r][idx_c] = prev_state[idx_r][idx_c];
          }
        }
      }
      prev_state = new_state;
    }
    var count_occupied = prev_state
        .map((line) => line.where((e) => e == '#').length)
        .reduce((a, b) => a + b);
    print('Part ${part}: ${count_occupied}');
  }

  solve(1);
  solve(2);
}

void day12() async {
  final input = await aoc2020.loadInput(12);
  var dirs = ['E', 'S', 'W', 'N'];
  var movs = {
    'E': [1, 0],
    'S': [0, -1],
    'W': [-1, 0],
    'N': [0, 1],
  };
  var dir = 0;
  var x = 0;
  var y = 0;
  for (var line in input) {
    var inst = line[0];
    var value = int.parse(line.substring(1));
    switch (inst) {
      case 'E':
      case 'S':
      case 'W':
      case 'N':
        var move = movs[inst];
        x += (move[0] * value);
        y += (move[1] * value);
        break;
      case 'L':
      case 'R':
        var turn_by = value ~/ 90;
        dir += ((inst == 'R') ? turn_by : -turn_by);
        dir %= 4;
        break;
      case 'F':
        var move = movs[dirs[dir]];
        x += (move[0] * value);
        y += (move[1] * value);
        break;
    }
  }
  var manhattan_distance_1 = x.abs() + y.abs();
  print('Part 1: ${manhattan_distance_1}');
  x = 0;
  y = 0;
  var w_x = 10;
  var w_y = 1;
  for (var line in input) {
    var inst = line[0];
    var value = int.parse(line.substring(1));
    switch (inst) {
      case 'E':
      case 'S':
      case 'W':
      case 'N':
        var move = movs[inst];
        w_x += (move[0] * value);
        w_y += (move[1] * value);
        break;
      case 'L':
      case 'R':
        var d_value = value * pi / 180;
        if (inst == 'R') {
          d_value = -d_value;
        }
        var old_x = w_x;
        w_x = cos(d_value).round() * w_x - sin(d_value).round() * w_y;
        w_y = sin(d_value).round() * old_x + cos(d_value).round() * w_y;
        break;
      case 'F':
        x += (w_x * value);
        y += (w_y * value);
        break;
    }
  }
  var manhattan_distance_2 = x.abs() + y.abs();
  print('Part 2: ${manhattan_distance_2}');
}

void day13() async {
  final input = await aoc2020.loadInput(13);
  final earliest_ts = int.parse(input[0]);
  final busses = input[1]
      .split(',')
      .where((bus) => bus != 'x')
      .map((bus) => int.parse(bus));
  final res = busses
      .map((time) => [((earliest_ts / time).ceil() * time) - earliest_ts, time])
      .reduce((curr, next) => curr[0] < next[0] ? curr : next);
  print('Part 1: ${res[0] * res[1]}');
  final idx_and_busses = input[1]
      .split(',')
      .asMap()
      .entries
      .map((val) => [val.key, val.value])
      .where((bus) => bus[1] != 'x')
      .map((bus) => [bus[0], int.parse(bus[1])]);
  var t = 0;
  var increment = busses.toList()[0];
  idx_and_busses.forEach((idx_and_bus) {
    var idx = idx_and_bus[0];
    var bus_id = idx_and_bus[1];
    var loop = true;
    while (loop) {
      t += increment;
      if ((t + idx) % bus_id == 0) {
        loop = false;
      }
    }
    increment = numerics.leastCommonMultiple(increment, bus_id);
  });

  print('Part 2: ${t}');
}

void day14() async {
  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  final input = await aoc2020.loadInput(14);
  var mem1 = {};
  var mem2 = {};
  var curr_mask = '';
  for (var line in input) {
    if (line.startsWith('mask')) {
      curr_mask = line.split('=')[1];
    } else {
      var matches =
          RegExp(r'mem[\[](\d+)[\]]\s=\s(\d+)').allMatches(line).elementAt(0);
      var idx = BigInt.parse(matches.group(1));
      var val = BigInt.parse(matches.group(2));

      // Part 1.
      var or_mask = BigInt.parse(curr_mask.replaceAll('X', '0'), radix: 2);
      var and_mask = BigInt.parse(curr_mask.replaceAll('X', '1'), radix: 2);
      mem1[idx] = (val & and_mask) | or_mask;

      // Part 2.

      var idxs_of_xs = quiver
          .enumerate(curr_mask.split(''))
          .where((idx_val) => idx_val.value == 'X')
          .map((idx_val) => idx_val.index)
          .toList();

      var merge_mask =
          (BigInt.parse(curr_mask.replaceAll('X', '0'), radix: 2) | idx)
              .toRadixString(2)
              .padLeft(curr_mask.length, '0');
      var possible_masks = [merge_mask];

      for (var i = 0; i < idxs_of_xs.length; i++) {
        var new_possible_masks = <String>[];
        for (var possible_mask in possible_masks) {
          new_possible_masks
              .add(replaceCharAt(possible_mask, idxs_of_xs[i], '1'));
          new_possible_masks
              .add(replaceCharAt(possible_mask, idxs_of_xs[i], '0'));
        }
        possible_masks = new_possible_masks;
      }
      for (var possible_mask in possible_masks) {
        var idx_to_use = BigInt.parse(possible_mask, radix: 2);
        mem2[idx_to_use] = val;
      }
    }
  }
  var sum1 = mem1.values.reduce((a, b) => a + b);
  var sum2 = mem2.values.reduce((a, b) => a + b);

  print('Part 1: ${sum1}');
  print('Part 1: ${sum2}');
}

void main(List<String> arguments) async {
  await day14();
}
