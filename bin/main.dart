/*
 * Copyright (c) 2022.
 * Created by Andy Pangaribuan. All Rights Reserved.
 *
 * This product is protected by copyright and distributed under
 * licenses restricting copying, distribution and decompilation.
 */

import 'package:dtg/dtg.dart';
import 'package:qw_cli/qw_cli.dart';

import 'command/k8s.dart';
import 'docker.dart';
import 'git.dart';
import 'workbench.dart';

class _CLI extends CLI {
  _CLI(List<List<String>> helpCommands) : super(helpCommands: helpCommands);

  final k8s = K8s();
  final docker = DockerCommand();
  final git = GitCommand();
  final workbench = WorkbenchCommand();
}

void main(List<String> arguments) {
  final c = _CLI([
    ['k8s', '→', 'show-pods'],
    ['docker', '→', '[image | ps]'],
    ['git', '→', 'diff-branch'],
    ['workbench', '→', 'psql-convert'],
  ]);

  dg.cli(arguments)
    ..route = [
      [c.notFound],
      ['', c.help],
      ['k8s', c.k8s.help],
      ['k8s show-pods', c.k8s.showPods],
      ['docker', c.docker.help],
      ['docker image', c.docker.image],
      ['docker ps', c.docker.ps],
      ['git', c.git.help],
      ['git diff-branch', c.git.diffBranch],
      ['workbench', c.workbench.help],
      ['workbench psql-convert', c.workbench.convert],
    ]
    ..run();
}
