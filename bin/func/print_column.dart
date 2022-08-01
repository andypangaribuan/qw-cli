void printColumn(List<List<String>> data, {Function(List<List<String>>)? sort}) {
  if (data.isEmpty) {
    return;
  }

  if (sort != null && data.length > 1) {
    final head = data[0];
    data.removeAt(0);
    sort(data);
    data.insert(0, head);
  }

  List<int> lsMax = List.generate(data[0].length, (index) {
    final columns = {for (var row in data) row[index]};
    final max = columns.fold<int>(0, (prev, e) => e.length > prev ? e.length : prev);
    return max;
  });

  String addSpace(int max, String value) {
    while (true) {
      if (value.length >= max) {
        break;
      }
      value += " ";
    }
    return value;
  }

  List<String> messages = [];
  for (var columns in data) {
    String message = "";
    for (int i = 0; i < columns.length; i++) {
      if (i == columns.length - 1) {
        message += columns[i];
      } else {
        message += addSpace(lsMax[i], columns[i]);
        message += "  ";
      }
    }
    messages.add(message);
  }

  for (var msg in messages) {
    print(msg);
  }
}
