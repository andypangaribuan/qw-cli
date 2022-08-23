/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'dart:io';

import 'package:dtg/dtg.dart';

import 'func.dart';

class GitCommand {

  void _help() {
    dg.print.table([
      ['git', '▶', 'diff-branch {branch-from} {branch-to}'],
    ]);
  }

  void help(Args ar) {
    if (ar.arg1.isNotEmpty) {
      printCommandNotFound();
    }
    _help();
  }

  void diffBranch(Args ar) async {
    if (ar.arg1.isEmpty || ar.arg2.isEmpty) {
      _help();
      return;
    }

    final workingDirectory = Directory.current.path;
    final command = 'git diff origin/${ar.arg1}..origin/${ar.arg2} --numstat';

    final res = await dg.sh.exec(command: command, workingDirectory: workingDirectory);
    if (res.exitCode != 0) {
      final messages = ['exit code: ${res.exitCode}'];
      if (res.stderr.isNotEmpty) {
        messages.add(res.stderr);
      }
      printLines(messages);
      return;
    }

    if (res.stdout.isEmpty) {
      print('empty output');
      return;
    }

    final lines = res.stdout.split('\n');
    final List<String> files = [];

    for (var line in lines) {
      final arr = line.split('\t');
      if (arr.length == 3) {
        final added = arr[0].trim();
        final deleted = arr[1].trim();
        final file = arr[2].trim();
        if (added != '0' || deleted != '0') {
          files.add(file);
        }
      }
    }

    printLines(files);
  }
}
