import 'package:dtg/dtg.dart';

import 'func.dart';

class DockerCommand {

  final _infoPrintAll = 'Enter * to print all';

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
    if (imageName != '*') {
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
    if (containerName != '*') {
      command += grepIncludeHeader(containerName);
    }

    final header = ['CONTAINER ID', 'IMAGE', 'COMMAND', 'CREATED', 'STATUS', 'PORTS', 'NAMES'];
    final display = ['IMAGE', 'NAMES', 'STATUS', 'PORTS'];
    final table = await dg.sh.table(command: command, lsHeader: header, display: display, transformer: (index, header, value) {
      if (index == 0) {
        switch (header) {
          case 'IMAGE':
            value += ' TAG';
            break;
        }
        return value;
      }

      switch (header) {
        case 'IMAGE':
          final idx = value.indexOf(':');
          if (idx > 0) {
            value = value.substring(idx+1);
          }
          break;
      }
      return value;
    },);

    dg.print.table(table, sort: (data) => data.sort(((a, b) => b[3].compareTo(a[3]))));
  }
}