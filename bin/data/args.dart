class Args {
  List<String> ls = [];
  Args(List<String> args) {
    ls.addAll(args);
  }

  Args pop() {
    ls.removeAt(0);
    return this;
  }

  String _a(int index) => ls.length >= index + 1 ? ls[index].trim() : "";

  String get a1 => _a(0);
  String get a2 => _a(1);
  String get a3 => _a(2);
  String get a4 => _a(3);
  String get a5 => _a(4);
}
