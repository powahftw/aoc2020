import 'dart:math';
import 'package:quiver/iterables.dart' as quiver;
import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:trotter/trotter.dart' as trotter;

import 'package:aoc2020/aoc2020.dart' as aoc2020;

void day1() async {
  final input = (await aoc2020.loadInput(1)).map(int.parse).toList();
  const should_sum_to = 2020;
  final seen = <int>{};
  input.forEach((number) {
    if (seen.contains(should_sum_to - number)) {
      print('Part 1: ${number * (should_sum_to - number)}');
    }
    seen.add(number);
  });

  for (var i = 0; i < input.length - 2; i++) {
    for (var j = i + 1; j < input.length - 1; j++) {
      final partial_sum = input[i] + input[j];
      if (seen.contains(should_sum_to - partial_sum)) {
        print('Part 2: ${input[i] * input[j] * (should_sum_to - partial_sum)}');
        return;
      }
    }
  }
}

void day2() async {
  final input = (await aoc2020.loadInput(2));
  var valid_passwords_p1 = 0;
  var valid_passwords_p2 = 0;
  input.forEach((line) {
    final s_line = line.split(' ');
    final range = s_line[0].split('-');
    final min = int.parse(range[0]);
    final max = int.parse(range[1]);
    final letter = s_line[1][0];
    final password = s_line[2];
    if (min <= letter.allMatches(password).length &&
        letter.allMatches(password).length <= max) {
      valid_passwords_p1 += 1;
    }
    ;
    if ((password[min - 1] == letter) ^ (password[max - 1] == letter)) {
      valid_passwords_p2 += 1;
    }
  });
  print('Part 1: ${valid_passwords_p1}');
  print('Part 1: ${valid_passwords_p2}');
}

int tree_encountered(input, slope_x, slope_y) {
  var tree_seen = 0;
  var x = 0;
  var max_x = input[0].length;
  for (var y = slope_y; y < input.length; y += slope_y) {
    x = (x + slope_x) % max_x;
    if (input[y][x] == '#') {
      tree_seen += 1;
    }
  }
  return tree_seen;
}

void day3() async {
  final input = await aoc2020.loadInput(3);
  final part1 = tree_encountered(input, 3, 1);
  print('Part 1: ${part1}');
  final slopes = [
    [1, 1],
    [3, 1],
    [5, 1],
    [7, 1],
    [1, 2]
  ];
  var res2 = 1;
  for (var slope in slopes) {
    res2 *= tree_encountered(input, slope[0], slope[1]);
  }
  print('Part 2: ${res2}');
}

bool has_passport_all_fields(tokens) {
  var required_fields = {'byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'};
  for (var token in tokens.map((token) => token.split(':')[0])) {
    if (required_fields.contains(token)) {
      required_fields.remove(token);
    }
  }
  return required_fields.isEmpty;
}

bool are_present_fields_valid(tokens) {
  for (var token in tokens.map((token) => token.split(':'))) {
    var field = token[0];
    var value = token[1];
    switch (field) {
      case 'byr':
        if (!(value.length == 4 &&
            int.parse(value) < 2003 &&
            int.parse(value) > 1919)) {
          return false;
        }
        break;
      case 'iyr':
        if (!(value.length == 4 &&
            int.parse(value) < 2021 &&
            int.parse(value) > 2009)) {
          return false;
        }
        break;
      case 'eyr':
        if (!(value.length == 4 &&
            int.parse(value) < 2031 &&
            int.parse(value) > 2019)) {
          return false;
        }
        break;
      case 'hgt':
        var dim = value.substring(value.length - 2);
        if (int.tryParse(value.substring(0, value.length - 2)) == null) {
          return false;
        }
        var num_value = int.parse(value.substring(0, value.length - 2));
        if (!((dim == 'cm') || (dim == 'in'))) {
          return false;
        }
        if (((dim == 'cm') && (num_value > 193 || num_value < 150))) {
          return false;
        }
        if (((dim == 'in') && (num_value < 59 || num_value > 76))) {
          return false;
        }
        break;
      case 'hcl':
        var exp = RegExp(r'#[a-f|\d]{6}');
        if (!(exp.hasMatch(value))) {
          return false;
        }
        break;
      case 'ecl':
        if (!{'amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'}
            .contains(value)) {
          return false;
        }
        break;
      case 'pid':
        if (!(value.length == 9 && (value) != null)) {
          return false;
        }
        break;
    }
  }
  return true;
}

List<String> separate_line_in_tokens(String line) {
  return line.split(' ').toList();
}

void day4() async {
  final input = await aoc2020.loadInput(4);
  var valid_passports_1 = 0;
  var valid_passports_2 = 0;
  var current_passport_tokens = [];
  for (var line in input) {
    if (line.isEmpty) {
      final all_fields_present =
          has_passport_all_fields(current_passport_tokens);
      valid_passports_1 += all_fields_present ? 1 : 0;
      valid_passports_2 += (all_fields_present &&
              are_present_fields_valid(current_passport_tokens))
          ? 1
          : 0;
      current_passport_tokens = [];
    } else {
      current_passport_tokens.addAll(separate_line_in_tokens(line));
    }
  }
  final all_fields_present = has_passport_all_fields(current_passport_tokens);
  valid_passports_1 += all_fields_present ? 1 : 0;
  valid_passports_2 +=
      (all_fields_present && are_present_fields_valid(current_passport_tokens))
          ? 1
          : 0;
  print('Part 1: ${valid_passports_1}');
  print('Part 2: ${valid_passports_2}');
}

int calculate_seat_id(String bsp) {
  final rows_part = bsp.substring(0, 7);
  final column_part = bsp.substring(bsp.length - 3);
  var l = 0, r = 127;
  for (var i = 0; i < rows_part.length; i++) {
    var middle = (r - l + 1) ~/ 2;
    if (rows_part[i] == 'F') {
      r -= middle;
    } else {
      l += middle;
    }
  }
  var row = l;
  l = 0;
  r = 7;
  for (var i = 0; i < column_part.length; i++) {
    var middle = (r - l + 1) ~/ 2;
    if (column_part[i] == 'L') {
      r -= middle;
    } else {
      l += middle;
    }
  }
  var column = l;
  return row * 8 + column;
}

void day5() async {
  final input = await aoc2020.loadInput(5);
  final seat_ids = input.map((line) => calculate_seat_id(line));
  final min_id = seat_ids.reduce(min);
  final max_id = seat_ids.reduce(max);
  final seen = seat_ids.toSet();
  var missing;
  for (var i = min_id; i < max_id; i++) {
    if (!(seen.contains(i))) {
      missing = i;
      break;
    }
  }
  print('Part 1: ${max_id}');
  print('Part 2: ${missing}');
}

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

void day15() async {
  final input = (await aoc2020.loadInput(15))
      .expand((line) => line.split(','))
      .map((n) => int.parse(n))
      .toList();

  void solve(int part) {
    final UP_TO = part == 1 ? 2020 : 30000000;
    var last_spoken = 0;
    var spoken_at = {};
    for (var idx = 0; idx < UP_TO; idx++) {
      if (idx < input.length) {
        last_spoken = input[idx];
        spoken_at[last_spoken] = [idx];
      } else {
        if (spoken_at.containsKey(last_spoken)) {
          var val = spoken_at[last_spoken];
          if (val.length > 1) {
            last_spoken = val[val.length - 1] - val[val.length - 2];
            spoken_at.putIfAbsent(last_spoken, () => []).add(idx);
          } else {
            last_spoken = 0;
            spoken_at[0].add(idx);
          }
        }
      }
    }
    print('Part ${part}: ${last_spoken}');
  }

  solve(1);
  solve(2);
}

void day16() async {
  final input = await aoc2020.loadInput(16);
  var section = 0;
  var error_rate = 0;
  var rules = {};
  var your_ticket = [];
  var valid_tickets = [];
  for (var line in input) {
    if (line.isEmpty) {
      section += 1;
      continue;
    }
    if (line.contains('your ticket') || line.contains('nearby tickets')) {
      continue;
    }
    if (section == 0) {
      var matches = RegExp(r'(.+):\s(\d+)-(\d+)\sor\s(\d+)-(\d+)')
          .allMatches(line)
          .elementAt(0);
      var field_name = matches.group(1);
      rules[field_name] = [
        int.parse(matches.group(2)),
        int.parse(matches.group(3)),
        int.parse(matches.group(4)),
        int.parse(matches.group(5))
      ];
    }
    if (section == 1) {
      your_ticket = line.split(',').map((val) => int.parse(val)).toList();
      continue;
    }
    if (section == 2) {
      bool isValid(int n) {
        return rules.values
            .where((val) =>
                (n >= val[0] && n <= val[1]) || (n >= val[2] && n <= val[3]))
            .isNotEmpty;
      }

      var values = line.split(',').map((val) => int.parse(val));
      var is_error_present = values.any((n) => !isValid(n));

      if (is_error_present) {
        error_rate += values.where((n) => !isValid(n)).fold(0, (a, b) => a + b);
      } else {
        valid_tickets.add(values.toList());
      }
    }
  }
  print('Part 1: ${error_rate}');

  var found_rules = List(your_ticket.length);
  for (var c_idx = 0; c_idx < valid_tickets[0].length; c_idx++) {
    var valid_rules = [];
    var need_to_satisfy = valid_tickets.map((values) => values[c_idx]);
    for (var rule in rules.keys) {
      var rule_range = rules[rule];
      var all_satisfy = need_to_satisfy.every((n) =>
          ((n >= rule_range[0] && n <= rule_range[1]) ||
              (n >= rule_range[2] && n <= rule_range[3])));
      if (all_satisfy) {
        valid_rules.add(rule);
      }
    }
    found_rules[c_idx] = valid_rules;
  }

  var all_found = false;
  var matched_rules = <dynamic>{};
  while (!all_found) {
    for (var i = 0; i < found_rules.length; i++) {
      if (found_rules[i].length == 1) {
        matched_rules.add(found_rules[i][0]);
      } else {
        found_rules[i] =
            found_rules[i].where((el) => !matched_rules.contains(el)).toList();
      }
    }
    all_found = found_rules.every((el) => el.length == 1);
  }

  var mul = 1;
  for (var idx = 0; idx < found_rules.length; idx++) {
    if (found_rules[idx][0].startsWith('departure')) {
      mul *= your_ticket[idx];
    }
  }

  print('Part 2: ${mul}');
}

void day17() async {
  final DIRS3D = trotter.Amalgams(3, [-1, 0, 1])();
  final DIRS4D = trotter.Amalgams(4, [-1, 0, 1])();

  List<List<List<String>>> generate3DList(int size) {
    return List.generate(size,
        (_) => List.generate(size, (_) => List.generate(size, (_) => '.')));
  }

  List<List<List<List<String>>>> generate4DList(int size) {
    return List.generate(size, (_) => generate3DList(size));
  }

  int getActiveNeighbours3D(List<List<List<String>>> l, int z, int y, int x) {
    var sum = 0;
    for (var dir in DIRS3D) {
      var dz = dir[0];
      var dy = dir[1];
      var dx = dir[2];
      if (dz == 0 && dy == 0 && dx == 0) {
        // Skip the cell itself.
        continue;
      }
      try {
        if (l[z + dz][y + dy][x + dx] == '#') {
          sum += 1;
        }
      } on RangeError {
        continue;
      }
    }
    return sum;
  }

  int getActiveNeighbours4D(
      List<List<List<List<String>>>> l, int k, int z, int y, int x) {
    var sum = 0;
    for (var dir in DIRS4D) {
      var dk = dir[0];
      var dz = dir[1];
      var dy = dir[2];
      var dx = dir[3];
      if (dk == 0 && dz == 0 && dy == 0 && dx == 0) {
        // Skip the cell itself.
        continue;
      }
      try {
        if (l[k + dk][z + dz][y + dy][x + dx] == '#') {
          sum += 1;
        }
      } on RangeError {
        continue;
      }
    }
    return sum;
  }

  final input = await aoc2020.loadInput(17);
  const SIMULATE_SIZE = 20;
  const middle = SIMULATE_SIZE ~/ 2;
  const SIMULATE_STEP = 6;
  var state3d = generate3DList(SIMULATE_SIZE);
  var state4d = generate4DList(SIMULATE_SIZE);
  var rows = input.length;
  var cols = input[0].length;
  for (var idx_r = 0; idx_r < rows; idx_r++) {
    for (var idx_c = 0; idx_c < cols; idx_c++) {
      var y = middle - (rows ~/ 2) + idx_r;
      var x = middle - (cols ~/ 2) + idx_c;
      var z = middle;
      var k = middle;
      state3d[z][y][x] = input[idx_r][idx_c];
      state4d[k][z][y][x] = input[idx_r][idx_c];
    }
  }

  for (var t = 0; t < SIMULATE_STEP; t++) {
    var new_state3d = generate3DList(SIMULATE_SIZE);
    for (var z = 0; z < SIMULATE_SIZE; z++) {
      for (var y = 0; y < SIMULATE_SIZE; y++) {
        for (var x = 0; x < SIMULATE_SIZE; x++) {
          var is_cell_active = state3d[z][y][x] == '#';
          var active_neighbours = getActiveNeighbours3D(state3d, z, y, x);
          if (active_neighbours == 3 ||
              (is_cell_active && (active_neighbours == 2))) {
            new_state3d[z][y][x] = '#';
          } else {
            new_state3d[z][y][x] = '.';
          }
        }
      }
    }
    state3d = new_state3d;
  }

  for (var t = 0; t < SIMULATE_STEP; t++) {
    var new_state4d = generate4DList(SIMULATE_SIZE);
    for (var k = 0; k < SIMULATE_SIZE; k++) {
      for (var z = 0; z < SIMULATE_SIZE; z++) {
        for (var y = 0; y < SIMULATE_SIZE; y++) {
          for (var x = 0; x < SIMULATE_SIZE; x++) {
            var is_cell_active = state4d[k][z][y][x] == '#';
            var active_neighbours = getActiveNeighbours4D(state4d, k, z, y, x);
            if (active_neighbours == 3 ||
                (is_cell_active && (active_neighbours == 2))) {
              new_state4d[k][z][y][x] = '#';
            } else {
              new_state4d[k][z][y][x] = '.';
            }
          }
        }
      }
    }
    state4d = new_state4d;
  }
  var active_cnt_3d = 0;
  for (var t_state in state3d) {
    for (var row in t_state) {
      active_cnt_3d += row.where((cell) => cell == '#').length;
    }
  }
  print('Part 1: ${active_cnt_3d}');

  var active_cnt_4d = 0;
  for (var t_state in state4d) {
    for (var dim in t_state) {
      for (var row in dim) {
        active_cnt_4d += row.where((cell) => cell == '#').length;
      }
    }
  }
  print('Part 2: ${active_cnt_4d}');
}

void main(List<String> arguments) async {
  await day17();
}
