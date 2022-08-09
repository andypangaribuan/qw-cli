// ignore: depend_on_referenced_packages
import 'package:dtg/dtg.dart';
import 'package:qw_cli/qw_cli.dart';

import 'docker.dart';

void main(List<String> arguments) {
  final c = _CLI([
    ['docker', '▶︎', 'image | ps'],
    ['workbench', '▶︎', 'convert'],
  ]);

  dg.cli(arguments)
  ..route = [
    [c.notFound],
    ['', c.help],
    ['docker', c.docker.help],
    ['docker image', c.docker.image],
    ['docker ps', c.docker.ps],
  ]
  ..run();
}

class _CLI extends CLI {
  _CLI(List<List<String>> helpCommands): super(helpCommands: helpCommands);

  final docker = DockerCommand();
}