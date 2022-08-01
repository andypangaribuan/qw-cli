import 'package:dcli/dcli.dart';

import '../data/args.dart';
import '../data/messages.dart';
import '../func/print_column.dart';
import '../shell/sh.dart';

final dockerCommand = DockerCommand._();

class DockerCommand {
  DockerCommand._();

  final commands = "images | ps";

  void main(Args args) {
    switch (args.a1) {
      case "":
        _help();
        break;
      case "images":
        _images(args.pop());
        break;
      case "ps":
        _ps(args.pop());
        break;
      default:
        print(messages.notFound);
    }
  }

  void _help() {
    printColumn([
      ["docker", "▶︎", commands]
    ]);
  }

  void _ps(Args args) async {
    var containerName = args.a1;
    if (containerName.isEmpty) {
      print('Enter * to print all');
      containerName = ask('Enter container name: ').trim();
    }

    var command = 'docker ps -a';
    if (containerName != '*') {
      command += ' | (read line; echo "\$line"; grep $containerName)';
    }

    final data = await shColumn(
      command,
      ["CONTAINER ID", "IMAGE", "COMMAND", "CREATED", "STATUS", "PORTS", "NAMES"],
      ["IMAGE", "NAMES", "STATUS", "PORTS"],
      transformer: (index, header, value) {
        if (index == 0) {
          switch (header) {
            case "IMAGE":
              value += " TAG";
              break;
          }
          return value;
        }

        switch (header) {
          case "IMAGE":
            final idx = value.indexOf(":");
            if (idx > 0) {
              value = value.substring(idx+1);
            }
            break;
        }
        return value;
      },
    );

    printColumn(data, sort: (data) => data.sort(((a, b) => b[3].compareTo(a[3]))));
  }

  void _images(Args args) async {
    var imageName = args.a1;
    if (imageName.isEmpty) {
      print('Enter * to print all');
      imageName = ask('Enter image name: ').trim();
    }
    
    var command = 'docker images';
    if (imageName != "*") {
      command += ' | (read line; echo "\$line"; grep $imageName)';
    }

    final data = await shColumn(
      command,
      ["REPOSITORY", "TAG", "IMAGE ID", "CREATED", "SIZE"],
      ["REPOSITORY", "TAG", "CREATED", "SIZE"]);
    
    printColumn(data, sort: (data) => data.sort((a,b) => b[1].compareTo(a[1])));
  }
}
