import 'dart:io';

Future<List<List<String>>> shColumn(
    String command, List<String> lsHeader, List<String> display,
    {String Function(int index, String header, String value)? transformer}) async {

  final res = await Process.run('bash', ['-c', command]);
  final out = res.stdout as String;

  List<String> lines = out.split('\n');
  int linesLength = lines.length;
  for (int i = 0; i < linesLength; i++) {
    lines[i] = lines[i].trim();
    if (lines[i].isEmpty) {
      lines.removeAt(i);
      i--;
      linesLength--;
    }
  }

  if (lines.isEmpty) {
    return [];
  }

  Map<String, List<int>> mapHeader = {};
  String header = lines[0];
  String item = "";
  int x = 0;
  bool find = false;

  for (int i = 0; i < header.length; i++) {
    final findHeader = lsHeader[mapHeader.length];
    final c = header.substring(i, i + 1);
    item += c;
    if (item.trim() == findHeader) {
      find = true;
    } else if (find) {
      mapHeader[findHeader] = [x, i];

      x = i;
      find = false;
      item = c;
      continue;
    }

    if (find && i == header.length - 1) {
      mapHeader[findHeader] = [x];
    }
  }

  List<List<String>> columns = [];
  for (var line in lines) {
    List<String> items = [];
    for (var header in display) {
      final m = mapHeader[header]!;
      var item = line.substring(m[0], m.length > 1 ? m[1] : null);
      items.add(item.trim());
    }
    columns.add(items);
  }

  if (transformer != null && columns.length > 1) {
    for (int i = 0; i < columns[0].length; i++) {
      final header = columns[0][i];
      for (int j = 0; j < columns.length; j++) {
        columns[j][i] = transformer(j, header, columns[j][i]);
      }
    }
  }

  return columns;
}
