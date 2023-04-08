/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dtg/dtg.dart';
import 'dart:io' as io;

import 'func.dart';

class WorkbenchCommand {
  void help(Args ar) {
    if (ar.arg1.isNotEmpty) {
      printCommandNotFound();
    }
    dg.print.table([
      ['workbench', '▶', 'psql-convert {path-to-sql-file} [--save | --drop-table]'],
    ]);
  }

  void convert(Args ar) async {
    final sqlFilePath = requiredArg(ar.arg1, msg: 'Enter path to sql file: ');
    final file = io.File(sqlFilePath);
    if (!(await file.exists())) {
      print('file not exists');
      return;
    }

    var lines = await file.readAsLines();
    lines = _removeUnused(lines);
    lines = _extractComment(lines);
    lines = _transformTableColumn(lines);
    lines = _beautifier(lines);


    if (ar.haveOpt('--drop-table')) {
      lines = _getDropTable(lines);
      if (ar.haveOpt('--save')) {
        final savedFilepath = await _saveToFile(sqlFilePath, lines);
        print('saved file: $savedFilepath');
      } else {
        printLines(lines);
      }
      return;
    }

    if (ar.haveOpt('--save')) {
      final savedFilepath = await _saveToFile(sqlFilePath, lines);
      print('saved file: $savedFilepath');
    } else {
      printLines(lines);
    }
  }

  List<String> _removeUnused(List<String> lines) {
    final newLines = <String>[];
    String dbName = '';

    for (var line in lines) {
      final l = line.trim().toLowerCase();
      final ls = l.length;

      if (l.isEmpty) {
        continue;
      }

      if (ls >= 2 && l.substring(0, 2) == '--') {
        continue;
      }

      if (ls >= 4) {
        final v = l.substring(0, 4);
        if (v == 'use ') {
          var l = line.trim().substring(4).trim();
          if (l.substring(l.length - 1) == ';') {
            l = l.substring(0, l.length - 1).trim();
          }
          dbName = l;
        }

        if (v == 'set ' || v == 'use ') {
          continue;
        }
      }

      if (ls >= 13 && l.substring(0, 13) == 'create schema') {
        continue;
      }

      if (ls >= 9 && l.substring(0, 9) == 'engine = ') {
        if (l.substring(ls - 1) == ';') {
          if (newLines.isNotEmpty) {
            newLines[newLines.length - 1] = '${newLines[newLines.length - 1]};';
            continue;
          }
        }
      }

      if (ls > 3 && l.substring(ls - 3) == '` ;') {
        line = line.substring(0, line.length - 2);
        line += ';';
      }

      if (ls > 12 && l.substring(0, 12) == 'create index' && l.substring(ls-9) == ' visible;') {
        line = '${line.substring(0, line.length-9)};';
      }

      switch (l) {
        case 'on delete no action':
        case 'on update no action':
          continue;
        case 'on delete no action)':
        case 'on update no action)':
          if (newLines.isNotEmpty) {
            newLines[newLines.length - 1] += ')';
          }
          continue;
      }

      newLines.add(line);
    }

    var all = newLines.join('\n');
    if (dbName.isNotEmpty) {
      all = all.replaceAll('$dbName.', '');
    }

    all = all.replaceAll('`', '');
    all = all.trim();

    return all.split('\n');
  }

  List<String> _extractComment(List<String> lines) {
    final newLines = <String>[];

    final commentKey = ' COMMENT ';
    var tableName = '';
    List<List<String>> comments = [];

    for (var line in lines) {
      final l = line.trim().toLowerCase();
      final ls = l.length;

      if (tableName.isEmpty && ls >= 26 && l.substring(0, 26) == 'create table if not exists') {
        var v = line.trim().substring(26);
        if (v.isNotEmpty) {
          v = v.substring(0, v.length - 1);
          tableName = v.trim();
          newLines.add(line);
          continue;
        }
      }

      if (tableName.isNotEmpty && ls >= 2 && l.substring(ls - 2) == ');') {
        newLines.add(line);

        for (var c in comments) {
          final comment = 'COMMENT ON COLUMN $tableName.${c[0]} IS ${c[1]};';
          newLines.add(comment);
        }

        tableName = '';
        comments.clear();
        continue;
      }

      final idx = line.indexOf(commentKey);
      if (idx > -1) {
        var ln = line.substring(0, idx);
        var v = line.substring(idx + commentKey.length).trim();
        final idxStart = v.indexOf('\'');
        final idxEnd = v.lastIndexOf('\'');

        if (idxStart == -1 || idxEnd == -1 || idxStart != 0) {
          print('malformed comment');
          print('line: $line');
          io.exit(-1);
        }

        final last = v.substring(idxEnd + 1);
        final columnName = ln.trim().split(' ')[0];
        v = v.substring(0, idxEnd + 1);

        comments.add([columnName, v]);

        ln += last;
        newLines.add(ln);
        continue;
      }

      newLines.add(line);
    }

    return newLines;
  }

  List<String> _transformTableColumn(List<String> lines) {
    final newLines = <String>[];

    var tableName = '';
    for (var line in lines) {
      final l = line.trim().toLowerCase();
      final ls = l.length;

      if (tableName.isEmpty && ls > 26 && l.substring(0, 26) == 'create table if not exists') {
        var v = l.substring(26);
        v = v.substring(0, v.length - 1);
        tableName = v.trim();
        newLines.add(line);
        continue;
      }

      if (tableName.isNotEmpty) {
        final arr = line.trim().split(' ');

        if (line.contains('AUTO_INCREMENT')) {
          var columnType = arr[1].trim();
          line = line.replaceFirst('AUTO_INCREMENT', '');
          switch (columnType.toLowerCase()) {
            case 'int':
              line = line.replaceFirst(columnType, 'SERIAL');
              break;
            case 'bigint':
              line = line.replaceFirst(columnType, 'BIGSERIAL');
              break;
          }
        }

        if (arr.length >= 2) {
          var columnType = arr[1].trim();

          if (columnType.length > 10 && columnType.toLowerCase().substring(0, 10) == 'timestamp(') {
            var v = columnType.substring(10);
            v = v.substring(0, v.length - 1);
            line = line.replaceFirst(columnType, 'TIMESTAMP($v) WITH TIME ZONE');
          }

          switch (columnType.toLowerCase()) {
            case 'tinyint':
              line = line.replaceFirst(columnType, 'BOOLEAN');
              break;
            case 'datetime':
              line = line.replaceFirst(columnType, 'TIMESTAMP');
              break;
            case 'timestamp':
              line = line.replaceFirst(columnType, 'TIMESTAMP(0) WITH TIME ZONE');
              break;
          }
        }

        var scanLength = 1;
        while (true) {
          final x = line.length - scanLength;
          final v = line.substring(x - scanLength, x - (scanLength - 1));
          if (v == ' ') {
            line = line.substring(0, x - scanLength) + line.substring(x);
            continue;
          }
          if (v == ')') {
            scanLength++;
            continue;
          }
          break;
        }

        if (ls > 2 && l.substring(ls - 2) == ');') {
          tableName = '';
        }
      }

      newLines.add(line);
    }

    return newLines;
  }

  List<String> _beautifier(List<String> lines) {
    final newLines = <String>[];

    for (var line in lines) {
      if (newLines.isEmpty) {
        newLines.add(line);
        continue;
      }

      final l = line.trim().toLowerCase();
      final ls = l.length;

      if (ls > 20 && l.substring(0, 20) == 'drop table if exists') {
        newLines.addAll(['', '', '']);
        // newLines.add(line);
        // continue;
      }

      if (ls > 17 && l.substring(0, 17) == 'comment on column') {
        final last = newLines[newLines.length - 1];
        if (last.length > 2 && last.substring(last.length - 2) == ');') {
          newLines.add('');
        }
      }

      if (ls > 12 && l.substring(0, 12) == 'create index') {
        final last = newLines[newLines.length - 1];
        if (last.length <= 12 || (last.length > 12 && last.substring(0, 12).toLowerCase() != 'create index')) {
          newLines.add('');
        }
      }

      newLines.add(line);
    }

    return newLines;
  }

  List<String> _getDropTable(List<String> lines) {
    final newLines = <String>[];

    for (int i=lines.length-1; i>=0; i--) {
      final line = lines[i];
      final l = line.trim().toLowerCase();
      final ls = l.length;

      if (ls > 20 && l.substring(0, 20) == 'drop table if exists') {
        newLines.add(line);
      }
    }

    return newLines;
  }

  Future<String> _saveToFile(String sqlFilePath, List<String> lines) async {
    final file = io.File(sqlFilePath);
    var filename = file.path.split(io.Platform.pathSeparator).last;
    if (filename.length > 4 && filename.substring(filename.length-4).toLowerCase() == '.sql') {
      filename = '${filename.substring(0, filename.length-4)}_p.sql';
    } else {
      filename += '_p.sql';
    }
    final dir = file.parent.path + io.Platform.pathSeparator;
    final savedFilepath = dir + filename;

    var f = io.File(savedFilepath);
    if (!(await f.exists())) {
    await f.create();
    }

    await f.writeAsString(lines.join('\n'));
    return savedFilepath;
  }
}
