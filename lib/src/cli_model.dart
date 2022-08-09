// ignore: depend_on_referenced_packages
import 'package:dtg/dtg.dart';

class CLI {

  final List<List<String>> _helpCommands = [];

  CLI({required List<List<String>> helpCommands}) {
    if (helpCommands.isNotEmpty) {
      _helpCommands.addAll(helpCommands);
    }
  }

  void notFound(Args ar) {
    print('command not found');
    print('');
    print('available command:');
    print('-----------------');
    help(ar);
  }

  void help(Args ar) {
    if (_helpCommands.isEmpty) {
      print('command help not initialize');
    } else {
      dg.print.table(_helpCommands);
    }
  }
}