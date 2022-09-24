/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dtg/dtg.dart';

import 'func.dart';

class DockerCommand {
  final _infoPrintAll = 'Enter . to print all';

  void help(Args ar) {
    if (ar.arg1.isNotEmpty) {
      printCommandNotFound();
    }
    dg.print.table([
      ['docker', '▶︎', 'image {image-name}'],
      ['docker', '▶︎', 'ps {container-name}'],
    ]);
  }

  void image(Args ar) async {
    final imageName = requiredArg(ar.arg1, info: _infoPrintAll, msg: 'Enter image name: ');
    var command = 'docker images';
    if (imageName != '.') {
      command += grepIncludeHeader(imageName);
    }

    final header = ['REPOSITORY', 'TAG', 'IMAGE ID', 'CREATED', 'SIZE'];
    final display = ['REPOSITORY', 'TAG', 'CREATED', 'SIZE'];
    final table = await dg.sh.table(command: command, lsHeader: header, display: display);
    dg.print.table(table);
  }

  void ps(Args ar) async {
    final containerName = requiredArg(ar.arg1, info: _infoPrintAll, msg: 'Enter container name: ');
    var command = 'docker ps -a';
    if (containerName != '.') {
      command += grepIncludeHeader(containerName);
    }

    final header = ['CONTAINER ID', 'IMAGE', 'COMMAND', 'CREATED', 'STATUS', 'PORTS', 'NAMES'];
    final display = ['IMAGE', 'NAMES', 'STATUS', 'PORTS'];
    final table = await dg.sh.table(
      command: command,
      lsHeader: header,
      display: display,
      transformer: (index, header, value) {
        // if (index == 0) {
        //   switch (header) {
        //     case 'IMAGE':
        //       value += ' TAG';
        //       break;
        //   }
        //   return value;
        // }

        switch (header) {
          case 'IMAGE':
            if (!ar.opt('--full-image')) {
              final ls = value.split('/');
              value = ls[ls.length - 1];
            }
            break;

          case 'PORTS':
            if (value.isNotEmpty && !ar.opt('--full-port')) {
              var newValue = '';
              void addNewValue(String v) {
                if (newValue != '') {
                  newValue += ', ';
                }
                newValue += v;
              }

              final containerPorts = <String>[];
              final mappingPorts = <String, List<String>>{};
              final ports = value.split(',');

              for (var port in ports) {
                port = port.trim();
                port = port.replaceAll('/tcp', '');
                port = port.replaceAll(':::', '');
                port = port.replaceAll('0.0.0.0:', '');

                final ls = port.split('->');
                if (ls.length == 1) {
                  if (!containerPorts.contains(port)) {
                    containerPorts.add(port);
                  }
                }
                if (ls.length == 2) {
                  final p = ls[0];
                  final v = '${ls[0]}->${ls[1]}';
                  var l = mappingPorts[p];
                  l ??= [];
                  if (!l.contains(v)) {
                    l.add(v);
                  }
                  mappingPorts[p] = l;
                }
              }

              for (var e in mappingPorts.entries) {
                for (var v in e.value) {
                  addNewValue(v);
                }
              }

              for (var v in containerPorts) {
                if (!mappingPorts.containsKey(v)) {
                  addNewValue(v);
                }
              }

              value += "";
              value = newValue;
            }
            break;
        }
        return value;
      },
    );

    var tableLength = table.length;
    if (containerName != '.' && tableLength > 1) {
      for (int i = 1; i < tableLength; i++) {
        final items = table[i];
        if (!items[0].contains(containerName) && !items[1].contains(containerName)) {
          table.removeAt(i);
          i--;
          tableLength--;
        }
      }
    }

    dg.print.table(table, sort: (data) => data.sort(((a, b) => b[3].compareTo(a[3]))));
  }
}
