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
  print('Part 2: ${valid_passwords_p2}');
}

int treeEncountered(input, slope_x, slope_y) {
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
  final part1 = treeEncountered(input, 3, 1);
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
    res2 *= treeEncountered(input, slope[0], slope[1]);
  }
  print('Part 2: ${res2}');
}

bool passportHasAllFields(tokens) {
  var required_fields = {'byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'};
  for (var token in tokens.map((token) => token.split(':')[0])) {
    if (required_fields.contains(token)) {
      required_fields.remove(token);
    }
  }
  return required_fields.isEmpty;
}

bool arePresentFieldsValid(tokens) {
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

void day4() async {
  final input = await aoc2020.loadInput(4);
  var valid_passports_1 = 0;
  var valid_passports_2 = 0;
  var current_passport_tokens = [];
  for (var line in input) {
    if (line.isEmpty) {
      final all_fields_present = passportHasAllFields(current_passport_tokens);
      valid_passports_1 += all_fields_present ? 1 : 0;
      valid_passports_2 +=
          (all_fields_present && arePresentFieldsValid(current_passport_tokens))
              ? 1
              : 0;
      current_passport_tokens = [];
    } else {
      current_passport_tokens.addAll(line.split(' ').toList());
    }
  }
  final all_fields_present = passportHasAllFields(current_passport_tokens);
  valid_passports_1 += all_fields_present ? 1 : 0;
  valid_passports_2 +=
      (all_fields_present && arePresentFieldsValid(current_passport_tokens))
          ? 1
          : 0;
  print('Part 1: ${valid_passports_1}');
  print('Part 2: ${valid_passports_2}');
}

int calculateSeatId(String bsp) {
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
  final seat_ids = input.map((line) => calculateSeatId(line));
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
      can_contain[fp] = <String, int>{};
    } else {
      can_contain[fp] = <String, int>{};
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
  print('Part 2: {$sum2}');
}

void day8() async {
  var input = await aoc2020.loadInput(8);
  var prog = input.map((line) => line.split(' ')).toList();

  int itCompletes(prog, zeroOnError) {
    var acc = 0;
    var idx = 0;
    var visited = <int>{};
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
      print('Part 1: ${sum_to}');
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
      print('Part 2: ${res}');
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
  int getNearby(List<List<String>> inp, int r, int c) {
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

  int getVisible(List<List<String>> inp, int r, int c) {
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
              ? getNearby(prev_state, idx_r, idx_c)
              : getVisible(prev_state, idx_r, idx_c);
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
  print('Part 2: ${sum2}');
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
  final DIRS3D =
      trotter.Amalgams(3, [-1, 0, 1])().where((l) => l.any((v) => v != 0));
  final DIRS4D =
      trotter.Amalgams(4, [-1, 0, 1])().where((l) => l.any((v) => v != 0));

  List<int> stringToInts(String s) {
    return s.split(',').map((v) => int.parse(v)).toList();
  }

  String intsToString(List<int> l) {
    return l.map((v) => v.toString()).join(',');
  }

  int getNearbyActive(String s, Set<String> b, int dimension) {
    var cnt = 0;
    final coord = stringToInts(s);
    final dirs = (dimension == 3) ? DIRS3D : DIRS4D;
    for (var dir in dirs) {
      final coords = [coord[0] + dir[0], coord[1] + dir[1], coord[2] + dir[2]];
      if (dimension == 4) {
        coords.add(coord[3] + dir[3]);
      }
      final isActive = b.contains(intsToString(coords));
      cnt += isActive ? 1 : 0;
    }
    return cnt;
  }

  final input = await aoc2020.loadInput(17);
  const SIMULATE_STEP = 6;

  var active3D = <String>{};
  var active4D = <String>{};

  for (var idxR = 0; idxR < input.length; idxR++) {
    for (var idxC = 0; idxC < input[idxR].length; idxC++) {
      if (input[idxR][idxC] == '#') {
        active3D.add(intsToString([idxR, idxC, 0]));
        active4D.add(intsToString([idxR, idxC, 0, 0]));
      }
    }
  }

  for (var t = 0; t < SIMULATE_STEP; t++) {
    final toCheck3D = <String>{};
    final newActive3D = <String>{};

    final toCheck4D = <String>{};
    final newActive4D = <String>{};

    // 3D Check
    for (var prevActive in active3D.toSet()) {
      final coords = stringToInts(prevActive);
      for (var dir in DIRS3D) {
        toCheck3D.add(intsToString(
            [coords[0] + dir[0], coords[1] + dir[1], coords[2] + dir[2]]));
      }
      toCheck3D.add(prevActive);
    }

    for (var potentialActive in toCheck3D.toSet()) {
      final nearbyActive = getNearbyActive(potentialActive, active3D, 3);

      final wasActive = active3D.contains(potentialActive);
      if ((nearbyActive == 3) || (wasActive && nearbyActive == 2)) {
        newActive3D.add(potentialActive);
      }
    }

    // 4D Check
    for (var prevActive in active4D.toSet()) {
      final coords = stringToInts(prevActive);
      for (var dir in DIRS4D) {
        toCheck4D.add(intsToString([
          coords[0] + dir[0],
          coords[1] + dir[1],
          coords[2] + dir[2],
          coords[3] + dir[3]
        ]));
      }
      toCheck4D.add(prevActive);
    }

    for (var potentialActive in toCheck4D.toSet()) {
      final nearbyActive = getNearbyActive(potentialActive, active4D, 4);

      final wasActive = active4D.contains(potentialActive);
      if ((nearbyActive == 3) || (wasActive && nearbyActive == 2)) {
        newActive4D.add(potentialActive);
      }
    }

    active3D = newActive3D;
    active4D = newActive4D;
  }

  print('Part 1: ${active3D.length}');
  print('Part 2: ${active4D.length}');
}

int parseNext(List<String> l, int part) {
  var el = l.removeLast();
  if (int.tryParse(el) != null) {
    return int.parse(el);
  } else if (el == '(') {
    var val = calc(l, part);
    l.removeLast(); // Remove ')'
    return val;
  }
  assert(false);
  return 0;
}

int calc(List<String> l, int part) {
  var val = parseNext(l, part);
  while (l.isNotEmpty && l.last != ')') {
    var el = l.removeLast();
    switch (el) {
      case '*':
        if (part == 1) {
          val *= parseNext(l, part);
        } else {
          val *= calc(l, part);
        }
        break;
      case '+':
        val += parseNext(l, part);
        break;
    }
  }
  return val;
}

void day18() async {
  final input = await aoc2020.loadInput(18);
  var sum1 = input
      .map((line) =>
          calc(line.split('').reversed.where((c) => c != ' ').toList(), 1))
      .reduce((a, b) => a + b);
  print('Part 1: ${sum1}');

  var sum2 = input
      .map((line) =>
          calc(line.split('').reversed.where((c) => c != ' ').toList(), 2))
      .reduce((a, b) => a + b);
  print('Part 2: ${sum2}');
}

void day19() async {
  final input = await aoc2020.loadInput(19);
  var is_rules_part = true;
  var rules = <int, dynamic>{};
  var messages = [];
  for (var line in input) {
    if (line.isEmpty) {
      is_rules_part = false;
      continue;
    }
    if (is_rules_part) {
      var split = line.split(':');
      var n = int.parse(split[0]);
      var sp = split[1].trim();
      if (sp.contains('"')) {
        rules[n] = RegExp(r'"(\D)"').allMatches(sp).elementAt(0).group(1);
      } else if (sp.contains('|')) {
        rules[n] = sp
            .trim()
            .split('|')
            .map((p) => p.trim())
            .map((p) => p.split(' ').map((v) => int.parse(v)))
            .toList();
      } else {
        rules[n] = [sp]
            .map((p) => p.split(' ').map((v) => int.parse(v.trim())))
            .toList();
      }
    } else {
      messages.add(line);
    }
  }
  final ROOT_RULE = 0;
  var cache = {};

  String buildRegex(Map<int, dynamic> rules, int rule, int p) {
    if (!(rules.containsKey(rule))) {
      assert(false);
    }
    if (p == 2 && rule == 8) {
      return '(${buildRegex(rules, 42, 1)}+)';
    }
    if (p == 2 && rule == 11) {
      var part_reg = '(';
      var a = buildRegex(rules, 42, 1);
      var b = buildRegex(rules, 31, 1);
      for (var i = 1; i < 10; i++) {
        if (i > 1) {
          part_reg += '|';
        }
        part_reg += '(';
        for (var j = 0; j < i; j++) {
          part_reg += a;
        }
        for (var j = 0; j < i; j++) {
          part_reg += b;
        }
        part_reg += ')';
      }
      part_reg += ')';
      return part_reg;
    }
    if (cache.containsKey(rule)) {
      return cache[rule];
    }
    var val = rules[rule];
    // Base
    if (val is String) {
      return val;
    }
    // List of list.
    var reg = '(';
    for (var idx = 0; idx < val.length; idx++) {
      if (idx != 0) {
        reg += '|';
      }
      for (var part in val[idx]) {
        reg += buildRegex(rules, part, p);
      }
    }
    cache[rule] = reg + ')';
    return cache[rule];
  }

  cache = {};
  var r1 = buildRegex(rules, ROOT_RULE, 1);
  var regex1 = RegExp(r1);
  print('Part 1: ${messages.where((m) => regex1.stringMatch(m) == m).length}');

  cache = {};

  var r2 = buildRegex(rules, ROOT_RULE, 2);
  var regex2 = RegExp(r2);
  print(regex2);
  // Used Python. Dart Regexp seemed to be too slow. https://github.com/dart-lang/sdk/issues/9360
  //print('Part 2: ${messages.where((m) => regex2.stringMatch(m) == m).length}');
}

void day20() async {
  int convToNum(String s) {
    return int.parse(s.replaceAll('#', '1').replaceAll('.', '0'), radix: 2);
  }

  String rev(String s) {
    return s.split('').reversed.join('');
  }

  List<String> convMap(List<String> l) {
    var r = l.length;
    var c = l[0].length;
    var top = l[0];
    var bottom = l[c - 1];
    var side_l = '';
    var side_r = '';
    for (var idx = 0; idx < r; idx++) {
      side_l += l[idx][0];
      side_r += l[idx][c - 1];
    }
    return [top, bottom, side_l, side_r];
  }

  final input = await aoc2020.loadInput(20);
  var puzzle = <String, List<String>>{};
  var curr_id = '';
  for (var line in input) {
    if (line.isEmpty) {
      continue;
    }
    if (line.startsWith('Tile')) {
      curr_id = RegExp(r'\s(\d+):').allMatches(line).elementAt(0).group(1);
      puzzle[curr_id] = [];
    } else {
      puzzle[curr_id].add(line);
    }
  }
  var cnt = {};
  var unique = {};
  for (var tile in puzzle.keys) {
    for (var n in convMap(puzzle[tile])) {
      cnt.putIfAbsent(convToNum(n), () => []).add(tile);
      cnt.putIfAbsent(convToNum(rev(n)), () => []).add(tile);
    }
  }
  for (var key in cnt.keys) {
    if (cnt[key].length == 1) {
      var tile = cnt[key][0];
      if (unique.containsKey(tile)) {
        unique[tile] += 1;
      } else {
        unique[tile] = 1;
      }
    }
  }
  // All corner will have 4 unmatched edges.
  var prod = 1;
  for (var key in unique.keys) {
    if (unique[key] == 4) {
      prod *= int.parse(key);
    }
  }

  print('Part 1: ${prod}');

  // Assumption, no multiple edges. Either they are single or they have only a pair.
  // 12 x 12
  // numpy
}

void day21() async {
  final input = await aoc2020.loadInput(21);
  var ing = <String>{};
  var ing_cnt = {};
  var alerg_to_ing = <String, Set>{};
  for (var line in input) {
    var parts = line.replaceAll('(', '').replaceAll(')', '').split('contains');
    var ingredients = parts[0].trim().split(' ').toSet();
    var alergens = parts[1].trim().split(',');

    ing = ing.union(ingredients);
    for (var ingredient in ingredients) {
      if (ing_cnt.containsKey(ingredient)) {
        ing_cnt[ingredient] += 1;
      } else {
        ing_cnt[ingredient] = 1;
      }
    }

    for (var alergen in alergens) {
      alergen = alergen.trim();
      if (alerg_to_ing.containsKey(alergen)) {
        alerg_to_ing[alergen] = alerg_to_ing[alergen].intersection(ingredients);
      } else {
        alerg_to_ing[alergen] = ingredients;
      }
    }
  }

  var all_alerg_candidate = alerg_to_ing.values.reduce((a, b) => a.union(b));
  var tot = 0;
  for (var ingredient in ing) {
    if (!(all_alerg_candidate.contains(ingredient))) {
      tot += ing_cnt[ingredient];
    }
  }
  print('Part 1: ${tot}');

  var found = {};
  var all_found = false;
  while (!all_found) {
    all_found = true;
    for (var alerg in alerg_to_ing.keys) {
      if (alerg_to_ing[alerg].length == 1) {
        var ing = alerg_to_ing[alerg].single;
        found[ing] = alerg;
      } else {
        all_found = false;
        alerg_to_ing[alerg] = alerg_to_ing[alerg]
            .where((ing) => !found.keys.contains(ing))
            .toSet();
      }
    }
  }
  var inv_found = found.map((k, v) => MapEntry(v, k));
  var res = '';
  for (var ing in inv_found.keys.toList()..sort()) {
    res += ',${inv_found[ing]}';
  }

  print('Part 2: ${res.substring(1)}');
}

void day22() async {
  int calculateScore(List<dynamic> cards) {
    var idx = 1;
    var res = 0;
    for (var val in cards.reversed) {
      res += val * idx;
      idx++;
    }
    return res;
  }

  final input = await aoc2020.loadInput(22);
  var p = 1;
  var p1card = [];
  var p2card = [];
  for (var line in input) {
    if (line.contains('Player')) {
      continue;
    }
    if (line.isEmpty) {
      p = 2;
      continue;
    }
    if (p == 1) {
      p1card.add(int.parse(line));
    } else {
      p2card.add(int.parse(line));
    }
  }
  // Game 1
  var p1 = [...p1card];
  var p2 = [...p2card];
  while (p1.isNotEmpty && p2.isNotEmpty) {
    var p1card = p1.removeAt(0);
    var p2card = p2.removeAt(0);
    if (p1card > p2card) {
      p1.addAll([p1card, p2card]);
    } else {
      p2.addAll([p2card, p1card]);
    }
  }
  var non_empty_pile = p1.isEmpty ? p2 : p1;

  print('Part 1: ${calculateScore(non_empty_pile)}');
  var last_winner_deck = [];

  int recursiveCombat(cp1, cp2) {
    var cache = <String>{};
    while (cp1.isNotEmpty && cp2.isNotEmpty) {
      var key = '${cp1.join(',')}-${cp2.join(',')}';
      if (cache.contains(key)) {
        return 1;
      } else {
        cache.add(key);
      }

      var p1card = cp1.removeAt(0);
      var p2card = cp2.removeAt(0);

      if (p1card <= cp1.length && p2card <= cp2.length) {
        var winner =
            recursiveCombat(cp1.sublist(0, p1card), cp2.sublist(0, p2card));
        if (winner == 1) {
          cp1.addAll([p1card, p2card]);
        } else {
          cp2.addAll([p2card, p1card]);
        }
      } else {
        if (p1card > p2card) {
          cp1.addAll([p1card, p2card]);
        } else {
          cp2.addAll([p2card, p1card]);
        }
      }
    }
    last_winner_deck = cp1.isEmpty ? cp2 : cp1;
    return cp1.isEmpty ? 2 : 1;
  }

  // Game 2
  recursiveCombat(p1card, p2card);
  print('Part 2: ${calculateScore(last_winner_deck)}');
}

class Node {
  int val;
  Node next;

  Node(this.val);
}

void day23() async {
  String getList(Node c, {int highlight = -1}) {
    var until = c.val;
    var res = '';
    while (c.next.val != until) {
      if (c.val == highlight) {
        res += '(${c.val})';
      } else {
        res += '${c.val}';
      }
      c = c.next;
    }
    if (c.val == highlight) {
      res += '(${c.val})';
    } else {
      res += '${c.val}';
    }
    return res;
  }

  final input = await aoc2020.loadInput(23);
  var cups = input[0].split('').map((n) => int.parse(n)).toList();

  Map<int, Node> solveCups(List<int> cups, int n_moves) {
    var max_val = cups.reduce(max);
    var min_val = cups.reduce(min);

    var idx_node = <int, Node>{};
    for (var idx = 1; idx < n_moves + 1; idx++) {
      idx_node[idx] = Node(idx);
    }

    for (var idx = 0; idx < cups.length; idx++) {
      idx_node[cups[idx]].next = idx_node[cups[(idx + 1) % cups.length]];
    }
    var curr = idx_node[cups[0]];
    for (var step = 0; step < n_moves; step++) {
      var curr_value = curr.val;

      var move_cups = [curr.next, curr.next.next, curr.next.next.next];
      var move_cups_val = move_cups.map((cup) => cup.val).toList();

      // Remove the next 3 by pointing the next to the 4th.
      curr.next = curr.next.next.next.next;

      var candidate_next = curr_value - 1;
      if (candidate_next < min_val) {
        candidate_next = max_val;
      }
      while (move_cups_val.contains(candidate_next)) {
        candidate_next -= 1;
        if (candidate_next < min_val) {
          candidate_next = max_val;
        }
      }

      var next = idx_node[candidate_next];
      var next_next = next.next;
      next.next = move_cups[0];
      move_cups[2].next = next_next;

      curr = curr.next;
    }
    return idx_node;
  }

  var p1 = solveCups(cups, 100);
  print('Part 1: ${getList(p1[1])}');

  var max_cup = cups.reduce(max);
  cups = cups + List<int>.generate(1000000 - max_cup, (i) => i + max_cup + 1);

  var p2 = solveCups(cups, 10000000);
  print('Part 2: ${p2[1].next.val * p2[1].next.next.val}');
}

void day24() async {
  final matchDir = RegExp(r'(e|se|sw|w|nw|ne)');
  const dirsToMove = {
    'e': [1, 0, -1],
    'se': [0, 1, -1],
    'sw': [-1, 1, 0],
    'w': [-1, 0, 1],
    'nw': [0, -1, 1],
    'ne': [1, -1, 0]
  };

  List<int> stringToInts(String s) {
    return s.split(',').map((v) => int.parse(v)).toList();
  }

  String intsToString(int x, int y, int z) {
    return [x, y, z].map((v) => v.toString()).join(',');
  }

  int getNearbyBlacks(String s, Set<String> b) {
    var cnt = 0;
    final coords = stringToInts(s);
    for (var dir in dirsToMove.values) {
      final isBlack = b.contains(intsToString(
          coords[0] + dir[0], coords[1] + dir[1], coords[2] + dir[2]));
      cnt += isBlack ? 1 : 0;
    }
    return cnt;
  }

  final input = await aoc2020.loadInput(24);

  var blackCells = <String>{};
  for (var line in input) {
    final curr = [0, 0, 0];
    for (var match in matchDir.allMatches(line)) {
      final dir = match.group(0);
      final move = dirsToMove[dir];
      curr[0] = curr[0] + move[0];
      curr[1] = curr[1] + move[1];
      curr[2] = curr[2] + move[2];
    }
    final finalPos = intsToString(curr[0], curr[1], curr[2]);
    if (blackCells.contains(finalPos)) {
      blackCells.remove(finalPos);
    } else {
      blackCells.add(finalPos);
    }
  }
  print('Part 1: ${blackCells.length}');

  for (var t = 0; t < 100; t++) {
    final toCheck = <String>{};
    final newBlacks = <String>{};

    for (var prevBlack in blackCells.toSet()) {
      final coords = stringToInts(prevBlack);
      for (var dir in dirsToMove.values) {
        toCheck.add(intsToString(
            coords[0] + dir[0], coords[1] + dir[1], coords[2] + dir[2]));
      }
      toCheck.add(intsToString(coords[0], coords[1], coords[2]));
    }

    for (var potentialBlack in toCheck.toSet()) {
      final nearbyBlacks = getNearbyBlacks(potentialBlack, blackCells);
      final wasBlack = blackCells.contains(potentialBlack);
      if ((!wasBlack && nearbyBlacks == 2) ||
          (wasBlack && (nearbyBlacks > 0 && nearbyBlacks < 3))) {
        newBlacks.add(potentialBlack);
      }
    }
    blackCells = newBlacks;
  }

  print('Part 2: ${blackCells.length}');
}

void day25() async {
  var MOD = 20201227;

  int getLoopSize(int val) {
    var curr = 1;
    for (var idx = 0; idx < 20000000; idx++) {
      curr *= 7;
      curr %= MOD;
      if (curr == val) {
        return idx + 1;
      }
    }
    return -1;
  }

  int pubToPriv(int val, int loop) {
    var enc_key = 1;
    for (var idx = 0; idx < loop; idx++) {
      enc_key *= val;
      enc_key %= MOD;
    }
    return enc_key;
  }

  final input = await aoc2020.loadInput(25);

  var card_pub_k = int.parse(input[0]);
  var door_pub_k = int.parse(input[1]);

  var card_ls = getLoopSize(card_pub_k);
  var door_ls = getLoopSize(door_pub_k);

  var c_priv_k = pubToPriv(card_pub_k, door_ls);
  var d_priv_k = pubToPriv(door_pub_k, card_ls);
  assert(c_priv_k == d_priv_k);
  print('Part 1: ${d_priv_k}');
}

void main(List<String> arguments) async {
  await day17();
}
