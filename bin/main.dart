/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dtg/dtg.dart';
import 'package:qw_cli/qw_cli.dart';

import 'docker.dart';
import 'workbench.dart';

void main(List<String> arguments) {
  final c = _CLI([
    ['docker', '▶︎', 'image | ps'],
    ['workbench', '▶︎', 'psql-convert'],
  ]);

  dg.cli(arguments)
  ..route = [
    [c.notFound],
    ['', c.help],
    ['docker', c.docker.help],
    ['docker image', c.docker.image],
    ['docker ps', c.docker.ps],
    ['workbench', c.workbench.help],
    ['workbench psql-convert', c.workbench.convert],
  ]
  ..run();
}

class _CLI extends CLI {
  _CLI(List<List<String>> helpCommands): super(helpCommands: helpCommands);

  final docker = DockerCommand();
  final workbench = WorkbenchCommand();
}