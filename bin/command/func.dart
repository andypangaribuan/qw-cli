/*
 * Copyright (c) 2023.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dcli/dcli.dart' show ask;
import 'package:dtg/dtg.dart';

void printEmpty() {
  print('');
}

void printCommandNotFound() {
  print('command not found');
  printEmpty();
  print('available command:');
  print('-----------------');
}

String grepIncludeHeader(String key) {
  return ' | (read line; echo "\$line"; grep $key)';
}

String requiredArg(String arg, {String info = '', required String msg, bool withNewLine = true}) {
  if (arg.isEmpty) {
    if (info.isNotEmpty) {
      print(info);
    }
    arg = ask(msg).trim();
    if (withNewLine) {
      printEmpty();
    }
  }

  return arg;
}

String requiredOpt(
  Args args, {
  required String opt,
  String? altOpt,
  String info = '',
  required String msg,
  bool withNewLine = true,
}) {
  var val = args.opt(opt);
  if (val == null && altOpt != null) {
    val = args.opt(altOpt);
  }

  if (val != null && val.isNotEmpty) {
    return val;
  }

  if (info.isNotEmpty) {
    print(info);
  }

  final v = ask(msg).trim();
  if (withNewLine) {
    printEmpty();
  }

  return v;
}

void printLines(List<String> lines) {
  for (var line in lines) {
    print(line);
  }
}
