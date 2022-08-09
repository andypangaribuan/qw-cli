/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dcli/dcli.dart' show ask;

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

String requiredArg(String arg, {String info = '', required String msg}) {
  if (arg.isEmpty) {
    if (info.isNotEmpty) {
      print(info);
    }
    arg = ask(msg).trim();
    printEmpty();
  }
  
  return arg;
}

void printLines(List<String> lines) {
  for (var line in lines) {
    print(line);
  }
}