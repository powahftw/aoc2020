import 'dart:math';
import 'package:quiver/iterables.dart' as quiver;
import 'package:quiver/collection.dart' as quiver;
import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:trotter/trotter.dart' as trotter;

import 'package:aoc2020/aoc2020.dart' as aoc2020;

void day1() async {
  final input = (await aoc2020.loadInput(1)).map(int.parse).toList();
  const shouldSumTo = 2020;
  final seen = <int>{};
  input.forEach((number) {
    if (seen.contains(shouldSumTo - number)) {
      print('Part 1: ${number * (shouldSumTo - number)}');
    }
    seen.add(number);
  });

  for (var i = 0; i < input.length - 2; i++) {
    for (var j = i + 1; j < input.length - 1; j++) {
      final partialSum = input[i] + input[j];
      if (seen.contains(shouldSumTo - partialSum)) {
        print('Part 2: ${input[i] * input[j] * (shouldSumTo - partialSum)}');
        return;
      }
    }
  }
}

void day2() async {
  final reg = RegExp(r'(\d+)-(\d+) (\D): (\D+)');
  final input = (await aoc2020.loadInput(2));
  var validPasswordsP1 = 0;
  var validPasswordsP2 = 0;
  input.forEach((line) {
    final matches = reg.allMatches(line).elementAt(0);
    final min = int.parse(matches.group(1));
    final max = int.parse(matches.group(2));
    final letter = matches.group(3);
    final password = matches.group(4);
    if (min <= letter.allMatches(password).length &&
        letter.allMatches(password).length <= max) {
      validPasswordsP1 += 1;
    }
    if ((password[min - 1] == letter) ^ (password[max - 1] == letter)) {
      validPasswordsP2 += 1;
    }
  });
  print('Part 1: ${validPasswordsP1}');
  print('Part 2: ${validPasswordsP2}');
}

int treeEncountered(input, slopeX, slopeY) {
  var seenTree = 0;
  var x = 0;
  var maxX = input[0].length;
  for (var y = slopeY; y < input.length; y += slopeY) {
    x = (x + slopeX) % maxX;
    if (input[y][x] == '#') {
      seenTree += 1;
    }
  }
  return seenTree;
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

bool passportHasAllFields(tokenAndVals, requiredFields) {
  final tokens = Set.from(tokenAndVals.map((token) => token.split(':')[0]));
  return requiredFields.every((field) => tokens.contains(field));
}

bool arePresentFieldsValid(tokens) {
  for (var token in tokens.map((token) => token.split(':'))) {
    final field = token[0];
    final value = token[1];
    switch (field) {
      case 'byr':
        if (!(int.parse(value) < 2003 && int.parse(value) > 1919)) {
          return false;
        }
        break;
      case 'iyr':
        if (!(int.parse(value) < 2021 && int.parse(value) > 2009)) {
          return false;
        }
        break;
      case 'eyr':
        if (!(int.parse(value) < 2031 && int.parse(value) > 2019)) {
          return false;
        }
        break;
      case 'hgt':
        var dim = value.substring(value.length - 2);
        if (int.tryParse(value.substring(0, value.length - 2)) == null) {
          return false;
        }
        var numValue = int.parse(value.substring(0, value.length - 2));
        if (!((dim == 'cm') || (dim == 'in'))) {
          return false;
        }
        if (((dim == 'cm') && (numValue > 193 || numValue < 150))) {
          return false;
        }
        if (((dim == 'in') && (numValue < 59 || numValue > 76))) {
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
        const allowedEyeColors = {
          'amb',
          'blu',
          'brn',
          'gry',
          'grn',
          'hzl',
          'oth'
        };
        if (!allowedEyeColors.contains(value)) {
          return false;
        }
        break;
      case 'pid':
        if (!(value.length == 9 && value != null)) {
          return false;
        }
        break;
    }
  }
  return true;
}

void day4() async {
  const requiredFields = {'byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'};
  final input = await aoc2020.loadInput(4);
  var validPassportsP1 = 0;
  var validPassportsP2 = 0;
  var currentPassportTokens = [];
  for (var line in [...input, '']) {
    if (line.isEmpty) {
      final allRequiredFieldsArePresent =
          passportHasAllFields(currentPassportTokens, requiredFields);
      validPassportsP1 += allRequiredFieldsArePresent ? 1 : 0;
      validPassportsP2 += (allRequiredFieldsArePresent &&
              arePresentFieldsValid(currentPassportTokens))
          ? 1
          : 0;
      currentPassportTokens = [];
    } else {
      currentPassportTokens.addAll(line.split(' ').toList());
    }
  }
  print('Part 1: ${validPassportsP1}');
  print('Part 2: ${validPassportsP2}');
}

int calculateSeatId(String bsp) {
  final bin =
      bsp.replaceAll(RegExp(r'F|L'), '0').replaceAll(RegExp(r'B|R'), '1');
  return int.parse(bin, radix: 2);
}

void day5() async {
  final input = await aoc2020.loadInput(5);
  final seatIds = input.map((line) => calculateSeatId(line));
  final minId = seatIds.reduce(min);
  final maxId = seatIds.reduce(max);
  final seen = seatIds.toSet();
  final expected = List<int>.generate(maxId - minId, (i) => i + minId);
  final missing = expected.firstWhere((n) => !seen.contains(n));
  print('Part 1: ${maxId}');
  print('Part 2: ${missing}');
}

void day6() async {
  final input = await aoc2020.loadInput(6);
  var sumCountsP1 = 0, sumCountsP2 = 0;
  final anySeen = <String>{};
  final allSeen = <String>{};
  var newGroup = true;
  for (var line in input) {
    if (line.isEmpty) {
      sumCountsP1 += anySeen.length;
      sumCountsP2 += allSeen.length;
      anySeen.clear();
      allSeen.clear();
      newGroup = true;
    } else {
      final chars = line.split('');
      anySeen.addAll(chars);
      if (newGroup) {
        allSeen.addAll(chars);
        newGroup = false;
      } else {
        for (var seenChar in List.from(allSeen)) {
          if (!line.contains(seenChar)) {
            allSeen.remove(seenChar);
          }
        }
      }
    }
  }
  sumCountsP1 += anySeen.length;
  sumCountsP2 += allSeen.length;
  print('Part 1: ${sumCountsP1}');
  print('Part 2: ${sumCountsP2}');
}

void day7() async {
  final colorRegExp = RegExp(r'(\d+)\s(\D+)');
  final input = await aoc2020.loadInput(7);
  final canContain = <String, Map<String, int>>{};
  for (var line in input) {
    if (line.isEmpty) {
      continue;
    }
    line = line.replaceAll('bags', '').replaceAll('bag', '');
    final part = line.split(' contain ');
    final fp = part[0].trim();
    final sp = part[1].replaceAll('.', '');
    canContain[fp] = <String, int>{};
    if (!sp.contains('no other')) {
      for (var color in sp.split(',')) {
        final matches = colorRegExp.allMatches(color).elementAt(0);
        final number = int.parse(matches.group(1));
        final colorName = matches.group(2).trim();
        canContain[fp][colorName] = number;
      }
    }
  }
  bool canReach(String from, String to) {
    if (canContain[from].containsKey(to)) {
      return true;
    }
    for (var reach in canContain[from].keys) {
      if (canReach(reach, to)) {
        return true;
      }
    }
    return false;
  }

  var sum = 0;
  for (var color in canContain.keys) {
    sum += canReach(color, 'shiny gold') ? 1 : 0;
  }

  int dfs(String from) {
    if (canContain[from].isEmpty) {
      return 1;
    }
    var sumSoFar = 1;
    for (var key in canContain[from].keys) {
      sumSoFar += canContain[from][key] * dfs(key);
    }
    return sumSoFar;
  }

  final sum2 = dfs('shiny gold') - 1; // Don't count the shiny gold bag itself.

  print('Part 1: ${sum}');
  print('Part 2: ${sum2}');
}

void day8() async {
  final input = await aoc2020.loadInput(8);
  final prog = input.map((line) => line.split(' ')).toList();

  int itCompletes(prog, zeroOnError) {
    var acc = 0;
    var idx = 0;
    final visited = <int>{};
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
    var prevInst = inst[0];
    if (prevInst == 'jmp') {
      inst[0] = 'nop';
    } else if (prevInst == 'nop') {
      inst[0] = 'jmp';
    }
    var res = itCompletes(prog, true);
    if (res != 0) {
      print('Part 2: ${res}');
      break;
    }
    inst[0] = prevInst;
  }
}

void day9() async {
  final input =
      (await aoc2020.loadInput(9)).map((sNum) => int.parse(sNum)).toList();
  const PREVIOUS = 25;
  var shouldSumUpTo;
  for (var idx = PREVIOUS; idx < input.length; idx++) {
    shouldSumUpTo = input[idx];
    var canIMake = false;
    for (var minuendIdx1 = idx - PREVIOUS;
        minuendIdx1 < idx - 1;
        minuendIdx1++) {
      for (var minuendIdx2 = minuendIdx1 + 1;
          minuendIdx2 < idx;
          minuendIdx2++) {
        if (input[minuendIdx2] + input[minuendIdx1] == shouldSumUpTo) {
          canIMake = true;
        }
      }
    }
    if (!canIMake) {
      print('Part 1: ${shouldSumUpTo}');
      break;
    }
  }
  for (var idx = 0; idx < input.length - 1; idx++) {
    var idx2 = idx + 1;
    var sumSoFar = input[idx] + input[idx2];
    while (idx2 < input.length && sumSoFar < shouldSumUpTo) {
      idx2 += 1;
      sumSoFar += input[idx2];
    }
    if (sumSoFar == shouldSumUpTo) {
      final range = input.sublist(idx, idx2);
      final res = range.reduce(min) + range.reduce(max);
      print('Part 2: ${res}');
      break;
    }
  }
}

void day10() async {
  final input =
      (await aoc2020.loadInput(10)).map((sNum) => int.parse(sNum)).toList();

  final deviceRating = input.reduce(max) + 3;
  input.addAll([0, deviceRating]);
  input.sort((a, b) => a.compareTo(b));
  final trimmedList = List<int>.from(input);
  final shiftedList = List<int>.from(input);
  shiftedList.remove(0);
  trimmedList.removeLast();
  final jumps =
      quiver.zip([trimmedList, shiftedList]).map((x) => x[1] - x[0]).toList();
  int countOccurrence(l, n) {
    return l.where((e) => e == n).toList().length;
  }

  final sol1 = countOccurrence(jumps, 1) * countOccurrence(jumps, 3);
  print('Part 1: ${sol1}');

  final ways = List.filled(input.length, 0);
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

  final input =
      (await aoc2020.loadInput(11)).map((line) => line.split('')).toList();
  final rowsN = input.length;
  final colsN = input[0].length;
  int getNearby(List<List<String>> inp, int r, int c) {
    var res = 0;
    for (var d in dirs) {
      final x = c + d[0];
      final y = r + d[1];
      if (x < 0 || x >= colsN) {
        continue;
      }
      if (y < 0 || y >= rowsN) {
        continue;
      }
      res += (inp[y][x] == '#') ? 1 : 0;
    }
    return res;
  }

  int getVisible(List<List<String>> inp, int r, int c) {
    var occ = 0;
    for (var d in dirs) {
      final dx = d[0];
      final dy = d[1];
      var newRow = r + dy;
      var newCol = c + dx;
      while (newRow >= 0 && newRow < rowsN && newCol >= 0 && newCol < colsN) {
        if (inp[newRow][newCol] == '#') {
          occ += 1;
          break;
        } else if (inp[newRow][newCol] == 'L') {
          break;
        }
        newRow += dy;
        newCol += dx;
      }
    }
    return occ;
  }

  void solve(int part) {
    var changed = true;
    var prevState = input;
    while (changed) {
      changed = false;
      var newState = List.generate(rowsN, (_) => List<String>(colsN));
      for (var idxR = 0; idxR < rowsN; idxR++) {
        for (var idxC = 0; idxC < colsN; idxC++) {
          final prevCell = prevState[idxR][idxC];
          final occupiedNearby = (part == 1)
              ? getNearby(prevState, idxR, idxC)
              : getVisible(prevState, idxR, idxC);
          final tooCrowded = (part == 1) ? 3 : 4;
          if (prevCell == 'L' && occupiedNearby == 0) {
            newState[idxR][idxC] = '#';
            changed = true;
          } else if (prevCell == '#' && occupiedNearby > tooCrowded) {
            newState[idxR][idxC] = 'L';
            changed = true;
          } else {
            newState[idxR][idxC] = prevState[idxR][idxC];
          }
        }
      }
      prevState = newState;
    }
    var countOccupied = prevState
        .map((line) => line.where((e) => e == '#').length)
        .reduce((a, b) => a + b);
    print('Part ${part}: ${countOccupied}');
  }

  solve(1);
  solve(2);
}

void day12() async {
  final input = await aoc2020.loadInput(12);
  const dirs = ['E', 'S', 'W', 'N'];
  const movs = {
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
        var turnBy = value ~/ 90;
        dir += ((inst == 'R') ? turnBy : -turnBy);
        dir %= 4;
        break;
      case 'F':
        var move = movs[dirs[dir]];
        x += (move[0] * value);
        y += (move[1] * value);
        break;
    }
  }
  var manhattanDistanceP1 = x.abs() + y.abs();
  print('Part 1: ${manhattanDistanceP1}');
  x = 0;
  y = 0;
  var waypointX = 10;
  var waypointY = 1;
  for (var line in input) {
    var inst = line[0];
    var value = int.parse(line.substring(1));
    switch (inst) {
      case 'E':
      case 'S':
      case 'W':
      case 'N':
        var move = movs[inst];
        waypointX += (move[0] * value);
        waypointY += (move[1] * value);
        break;
      case 'L':
      case 'R':
        var dValue = value * pi / 180;
        if (inst == 'R') {
          dValue = -dValue;
        }
        var oldX = waypointX;
        waypointX =
            cos(dValue).round() * waypointX - sin(dValue).round() * waypointY;
        waypointY =
            sin(dValue).round() * oldX + cos(dValue).round() * waypointY;
        break;
      case 'F':
        x += (waypointX * value);
        y += (waypointY * value);
        break;
    }
  }
  var manhattanDistanceP2 = x.abs() + y.abs();
  print('Part 2: ${manhattanDistanceP2}');
}

void day13() async {
  final input = await aoc2020.loadInput(13);
  final earliestTimestamp = int.parse(input[0]);
  final busses = input[1]
      .split(',')
      .where((bus) => bus != 'x')
      .map((bus) => int.parse(bus));
  final res = busses
      .map((time) => [
            ((earliestTimestamp / time).ceil() * time) - earliestTimestamp,
            time
          ])
      .reduce((curr, next) => curr[0] < next[0] ? curr : next);
  print('Part 1: ${res[0] * res[1]}');
  final idxAndBusses = input[1]
      .split(',')
      .asMap()
      .entries
      .map((val) => [val.key, val.value])
      .where((bus) => bus[1] != 'x')
      .map((bus) => [bus[0], int.parse(bus[1])]);
  var t = 0;
  var increment = busses.toList()[0];
  idxAndBusses.forEach((idxAndBus) {
    var idx = idxAndBus[0];
    var busId = idxAndBus[1];
    var loop = true;
    while (loop) {
      t += increment;
      if ((t + idx) % busId == 0) {
        loop = false;
      }
    }
    increment = numerics.leastCommonMultiple(increment, busId);
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
  final mem1 = {};
  final mem2 = {};
  var currMask = '';
  for (var line in input) {
    if (line.startsWith('mask')) {
      currMask = line.split('=')[1];
    } else {
      var matches =
          RegExp(r'mem[\[](\d+)[\]]\s=\s(\d+)').allMatches(line).elementAt(0);
      var idx = BigInt.parse(matches.group(1));
      var val = BigInt.parse(matches.group(2));

      // Part 1.
      var orMask = BigInt.parse(currMask.replaceAll('X', '0'), radix: 2);
      var andMask = BigInt.parse(currMask.replaceAll('X', '1'), radix: 2);
      mem1[idx] = (val & andMask) | orMask;

      // Part 2.

      final idxsOfXs = quiver
          .enumerate(currMask.split(''))
          .where((idxVal) => idxVal.value == 'X')
          .map((idxVal) => idxVal.index)
          .toList();

      final mergeMask =
          (BigInt.parse(currMask.replaceAll('X', '0'), radix: 2) | idx)
              .toRadixString(2)
              .padLeft(currMask.length, '0');
      var possibleMasks = [mergeMask];

      for (var i = 0; i < idxsOfXs.length; i++) {
        var newPossibleMasks = <String>[];
        for (var possibleMask in possibleMasks) {
          newPossibleMasks.add(replaceCharAt(possibleMask, idxsOfXs[i], '1'));
          newPossibleMasks.add(replaceCharAt(possibleMask, idxsOfXs[i], '0'));
        }
        possibleMasks = newPossibleMasks;
      }
      for (var possibleMask in possibleMasks) {
        var idxToUse = BigInt.parse(possibleMask, radix: 2);
        mem2[idxToUse] = val;
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
    final upTo = (part == 1) ? 2020 : 30000000;
    final lastSeen = <int, List<int>>{};

    for (var idx = 0; idx < input.length; idx++) {
      lastSeen[input[idx]] = [idx];
    }

    var lastNumber = input[input.length - 1];
    for (var idx = input.length; idx < upTo; idx++) {
      if (lastSeen.containsKey(lastNumber)) {
        final seenAt = lastSeen[lastNumber];
        if (seenAt.length > 1) {
          lastNumber = seenAt[seenAt.length - 1] - seenAt[seenAt.length - 2];
          lastSeen.putIfAbsent(lastNumber, () => []).add(idx);
        } else {
          lastNumber = 0;
          lastSeen[0].add(idx);
        }
      }
    }
    print('Part ${part}: ${lastNumber}');
  }

  solve(1);
  solve(2);
}

void day16() async {
  final input = await aoc2020.loadInput(16);
  var section = 0;
  var errorRate = 0;
  final rules = {};
  final validTickets = [];
  var yourTicket = [];

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
      var fieldName = matches.group(1);
      rules[fieldName] = [
        int.parse(matches.group(2)),
        int.parse(matches.group(3)),
        int.parse(matches.group(4)),
        int.parse(matches.group(5))
      ];
    }
    if (section == 1) {
      yourTicket = line.split(',').map((val) => int.parse(val)).toList();
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
      var isErrorPresent = values.any((n) => !isValid(n));

      if (isErrorPresent) {
        errorRate += values.where((n) => !isValid(n)).fold(0, (a, b) => a + b);
      } else {
        validTickets.add(values.toList());
      }
    }
  }
  print('Part 1: ${errorRate}');

  var foundRules = List(yourTicket.length);
  for (var cIdx = 0; cIdx < validTickets[0].length; cIdx++) {
    final validRules = [];
    final needToSatisfy = validTickets.map((values) => values[cIdx]);
    for (var rule in rules.keys) {
      final ruleRange = rules[rule];
      final allSatisfy = needToSatisfy.every((n) =>
          ((n >= ruleRange[0] && n <= ruleRange[1]) ||
              (n >= ruleRange[2] && n <= ruleRange[3])));
      if (allSatisfy) {
        validRules.add(rule);
      }
    }
    foundRules[cIdx] = validRules;
  }

  var allFound = false;
  final matchedRules = <dynamic>{};
  while (!allFound) {
    for (var i = 0; i < foundRules.length; i++) {
      if (foundRules[i].length == 1) {
        matchedRules.add(foundRules[i][0]);
      } else {
        foundRules[i] =
            foundRules[i].where((el) => !matchedRules.contains(el)).toList();
      }
    }
    allFound = foundRules.every((el) => el.length == 1);
  }

  var mul = 1;
  for (var idx = 0; idx < foundRules.length; idx++) {
    if (foundRules[idx][0].startsWith('departure')) {
      mul *= yourTicket[idx];
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
  final el = l.removeLast();
  if (int.tryParse(el) != null) {
    return int.parse(el);
  } else if (el == '(') {
    final val = calc(l, part);
    l.removeLast(); // Remove ')'
    return val;
  }
  assert(false);
  return 0;
}

int calc(List<String> l, int part) {
  var val = parseNext(l, part);
  while (l.isNotEmpty && l.last != ')') {
    final el = l.removeLast();
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
  final sum1 = input
      .map((line) =>
          calc(line.split('').reversed.where((c) => c != ' ').toList(), 1))
      .reduce((a, b) => a + b);
  print('Part 1: ${sum1}');

  final sum2 = input
      .map((line) =>
          calc(line.split('').reversed.where((c) => c != ' ').toList(), 2))
      .reduce((a, b) => a + b);
  print('Part 2: ${sum2}');
}

void day19() async {
  final input = await aoc2020.loadInput(19);
  var isRulesPart = true;
  final rules = <int, dynamic>{};
  final messages = [];
  for (var line in input) {
    if (line.isEmpty) {
      isRulesPart = false;
      continue;
    }
    if (isRulesPart) {
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
  final cache = {};

  String buildRegex(Map<int, dynamic> rules, int rule, int p) {
    if (!(rules.containsKey(rule))) {
      assert(false);
    }
    if (p == 2 && rule == 8) {
      return '(${buildRegex(rules, 42, 1)}+)';
    }
    if (p == 2 && rule == 11) {
      var regExpBuilder = '(';
      var a = buildRegex(rules, 42, 1);
      var b = buildRegex(rules, 31, 1);
      for (var i = 1; i < 10; i++) {
        if (i > 1) {
          regExpBuilder += '|';
        }
        regExpBuilder += '(';
        for (var j = 0; j < i; j++) {
          regExpBuilder += a;
        }
        for (var j = 0; j < i; j++) {
          regExpBuilder += b;
        }
        regExpBuilder += ')';
      }
      regExpBuilder += ')';
      return regExpBuilder;
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

  cache.clear();
  final r1 = buildRegex(rules, ROOT_RULE, 1);
  final regex1 = RegExp(r1);
  print('Part 1: ${messages.where((m) => regex1.stringMatch(m) == m).length}');

  cache.clear();

  // Used Python. Dart Regexp seemed to be too slow. https://github.com/dart-lang/sdk/issues/9360
  // var r2 = buildRegex(rules, ROOT_RULE, 2);
  // var regex2 = RegExp(r2);
  // print(regex2);
  // print('Part 2: ${messages.where((m) => regex2.stringMatch(m) == m).length}');
}

void day20() async {
  int convToNum(String s) {
    return int.parse(s.replaceAll('#', '1').replaceAll('.', '0'), radix: 2);
  }

  String rev(String s) {
    return s.split('').reversed.join('');
  }

  List<String> convMap(List<String> l) {
    final r = l.length;
    final c = l[0].length;
    final top = l[0];
    final bottom = l[c - 1];
    var sideLeft = '';
    var sideRight = '';
    for (var idx = 0; idx < r; idx++) {
      sideLeft += l[idx][0];
      sideRight += l[idx][c - 1];
    }
    return [top, bottom, sideLeft, sideRight];
  }

  final input = await aoc2020.loadInput(20);
  final puzzle = <String, List<String>>{};
  var currId = '';
  for (var line in input) {
    if (line.isEmpty) {
      continue;
    }
    if (line.startsWith('Tile')) {
      currId = RegExp(r'\s(\d+):').allMatches(line).elementAt(0).group(1);
      puzzle[currId] = [];
    } else {
      puzzle[currId].add(line);
    }
  }
  final cnt = {};
  final unique = {};
  for (var tile in puzzle.keys) {
    for (var n in convMap(puzzle[tile])) {
      cnt.putIfAbsent(convToNum(n), () => []).add(tile);
      cnt.putIfAbsent(convToNum(rev(n)), () => []).add(tile);
    }
  }
  for (var key in cnt.keys) {
    if (cnt[key].length == 1) {
      final tile = cnt[key][0];
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
  var ingredients = <String>{};
  final ingredientsCount = {};
  final alergensToIngredients = <String, Set>{};
  for (var dish in input) {
    final parts =
        dish.replaceAll('(', '').replaceAll(')', '').split('contains');
    final dishIngredients = parts[0].trim().split(' ').toSet();
    final dishAlergens = parts[1].split(',');

    ingredients = ingredients.union(dishIngredients);
    for (var ingredient in dishIngredients) {
      if (ingredientsCount.containsKey(ingredient)) {
        ingredientsCount[ingredient] += 1;
      } else {
        ingredientsCount[ingredient] = 1;
      }
    }

    for (var alergen in dishAlergens) {
      alergen = alergen.trim();
      if (alergensToIngredients.containsKey(alergen)) {
        alergensToIngredients[alergen] =
            alergensToIngredients[alergen].intersection(dishIngredients);
      } else {
        alergensToIngredients[alergen] = dishIngredients;
      }
    }
  }

  var allIngredientsWithPotentialAlergens =
      alergensToIngredients.values.reduce((a, b) => a.union(b));
  var tot = 0;
  for (var ingredient in ingredients) {
    if (!(allIngredientsWithPotentialAlergens.contains(ingredient))) {
      tot += ingredientsCount[ingredient];
    }
  }
  print('Part 1: ${tot}');

  final found = {};
  var allFound = false;
  while (!allFound) {
    allFound = true;
    for (var alerg in alergensToIngredients.keys) {
      if (alergensToIngredients[alerg].length == 1) {
        final ing = alergensToIngredients[alerg].single;
        found[ing] = alerg;
      } else {
        allFound = false;
        alergensToIngredients[alerg] = alergensToIngredients[alerg]
            .where((ing) => !found.keys.contains(ing))
            .toSet();
      }
    }
  }
  var alergToIngredient = found.map((k, v) => MapEntry(v, k));
  var res = '';
  for (var ing in alergToIngredient.keys.toList()..sort()) {
    res += ',${alergToIngredient[ing]}';
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
  final p1card = [];
  final p2card = [];
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
  final p1 = [...p1card];
  final p2 = [...p2card];
  while (p1.isNotEmpty && p2.isNotEmpty) {
    var p1card = p1.removeAt(0);
    var p2card = p2.removeAt(0);
    if (p1card > p2card) {
      p1.addAll([p1card, p2card]);
    } else {
      p2.addAll([p2card, p1card]);
    }
  }
  var nonEmptyPile = p1.isEmpty ? p2 : p1;

  print('Part 1: ${calculateScore(nonEmptyPile)}');
  var lastWinnerDeck = [];

  int recursiveCombat(cp1, cp2) {
    var cache = <String>{};
    while (cp1.isNotEmpty && cp2.isNotEmpty) {
      var key = '${cp1.join(',')}-${cp2.join(',')}';
      if (cache.contains(key)) {
        return 1;
      } else {
        cache.add(key);
      }

      final p1card = cp1.removeAt(0);
      final p2card = cp2.removeAt(0);

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
    lastWinnerDeck = cp1.isEmpty ? cp2 : cp1;
    return cp1.isEmpty ? 2 : 1;
  }

  // Game 2
  recursiveCombat(p1card, p2card);
  print('Part 2: ${calculateScore(lastWinnerDeck)}');
}

class Node {
  int val;
  Node next;

  Node(this.val);
}

void day23() async {
  String getList(Node c, {int highlight = -1}) {
    final until = c.val;
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

  Map<int, Node> solveCups(List<int> cups, int nMoves) {
    final maxValue = cups.reduce(max);
    final minValue = cups.reduce(min);

    final idxToNode = <int, Node>{};
    for (var idx = 1; idx < nMoves + 1; idx++) {
      idxToNode[idx] = Node(idx);
    }

    for (var idx = 0; idx < cups.length; idx++) {
      idxToNode[cups[idx]].next = idxToNode[cups[(idx + 1) % cups.length]];
    }
    var curr = idxToNode[cups[0]];
    for (var step = 0; step < nMoves; step++) {
      var currentValue = curr.val;

      final cupsToMove = [curr.next, curr.next.next, curr.next.next.next];
      final cupsToMoveValues = cupsToMove.map((cup) => cup.val).toList();

      // Remove the next 3 by pointing the next to the 4th.
      curr.next = curr.next.next.next.next;

      var candidateNext = currentValue - 1;
      if (candidateNext < minValue) {
        candidateNext = maxValue;
      }
      while (cupsToMoveValues.contains(candidateNext)) {
        candidateNext -= 1;
        if (candidateNext < minValue) {
          candidateNext = maxValue;
        }
      }

      var next = idxToNode[candidateNext];
      var nextNext = next.next;
      next.next = cupsToMove[0];
      cupsToMove[2].next = nextNext;

      curr = curr.next;
    }
    return idxToNode;
  }

  var p1 = solveCups(cups, 100);
  print('Part 1: ${getList(p1[1])}');

  final maxCup = cups.reduce(max);
  cups = cups + List<int>.generate(1000000 - maxCup, (i) => i + maxCup + 1);

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
  const MOD = 20201227;

  int getLoopSize(int val) {
    var curr = 1;
    for (var idx = 0; idx < MOD; idx++) {
      curr *= 7;
      curr %= MOD;
      if (curr == val) {
        return idx + 1;
      }
    }
    return -1;
  }

  int pubToPriv(int val, int loop) {
    var candidateEncKey = 1;
    for (var idx = 0; idx < loop; idx++) {
      candidateEncKey *= val;
      candidateEncKey %= MOD;
    }
    return candidateEncKey;
  }

  final input = await aoc2020.loadInput(25);

  final cardPublicKey = int.parse(input[0]);
  final doorPublicKey = int.parse(input[1]);

  final cardLoopSize = getLoopSize(cardPublicKey);
  final doorLoopSize = getLoopSize(doorPublicKey);

  final cardPrivateKey = pubToPriv(cardPublicKey, doorLoopSize);
  final doorPrivateKey = pubToPriv(doorPublicKey, cardLoopSize);
  assert(cardPrivateKey == doorPrivateKey);
  print('Part 1: ${doorPrivateKey}');
}

void main(List<String> arguments) async {
  await day1();
  await day2();
  await day3();
  await day4();
  await day5();
  await day6();
  await day7();
  await day8();
  await day9();
  await day10();
  await day11();
  await day12();
  await day13();
  await day14();
  await day15();
  await day16();
  await day17();
  await day18();
  await day19();
  await day20();
  await day21();
  await day22();
  await day23();
  await day24();
}
