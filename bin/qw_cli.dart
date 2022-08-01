import 'cmd/docker.dart';
import 'data/args.dart';
import 'data/messages.dart';
import 'func/print_column.dart';

void main(List<String> arguments) {
  final args = Args(arguments);
  switch (args.a1) {
    case "":
      _help();
      break;
    case "docker":
      dockerCommand.main(args.pop());
      break;
    default:
      print(messages.notFound);
  }
}

void _help() {
//   print('''
// # ----------
// # 🚀 qw cli
// # ----------''');
//   print("");
  printColumn([
    ["docker", "▶︎", dockerCommand.commands],
    ["workbench", "▶︎", "convert"]
  ]);
}
