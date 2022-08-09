import 'package:dcli/dcli.dart' show ask;

void printEmpty() {
  print('');
}

void printCommandNotFound() {
  print('command not found');
  printEmpty();
  print('available command:');
  print('-----------------');
}

String grepIncludeHeader(String key) {
  return ' | (read line; echo "\$line"; grep $key)';
}

String requiredArg(String arg, {required String info, required String msg}) {
  if (arg.isEmpty) {
    print(info);
    arg = ask(msg).trim();
    printEmpty();
  }
  
  return arg;
}