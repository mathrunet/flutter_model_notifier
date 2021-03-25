part of model_notifier;

extension _LocalStringMapExtensions on Map<String, dynamic> {
  T? _readFromPath<T>(String path) {
    final paths = path.split("/");
    if (paths.isEmpty) {
      return null;
    }
    return _readFromPathInternal(paths, 0) as T;
  }

  dynamic _readFromPathInternal(List<String> paths, int index) {
    if (paths.length <= index) {
      return this;
    }
    final p = paths[index];
    if (p.isEmpty || !containsKey(p)) {
      return null;
    }
    if (this[p] is Map<String, dynamic>)
      return (this[p] as Map<String, dynamic>)
          ._readFromPathInternal(paths, index + 1);
    return this[p];
  }

  void _writeToPath(String path, dynamic value) {
    final paths = path.split("/");
    if (paths.isEmpty) {
      return;
    }
    _writeToPathInternal(paths, 0, value);
  }

  void _writeToPathInternal(List<String> paths, int index, dynamic value) {
    if (paths.length - 1 <= index) {
      remove(paths[index]);
      this[paths[index]] = value;
      return;
    }
    final p = paths[index];
    if (p.isEmpty) {
      return;
    }
    if (!containsKey(p) ||
        this[p] == null ||
        this[p] is! Map<String, dynamic>) {
      this[p] = <String, dynamic>{};
    }
    (this[p] as Map<String, dynamic>)
        ._writeToPathInternal(paths, index + 1, value);
  }

  void _deleteFromPath(String path) {
    final paths = path.split("/");
    if (paths.isEmpty) {
      return;
    }
    _deleteFromPathInternal(paths, 0);
  }

  void _deleteFromPathInternal(List<String> paths, int index) {
    if (paths.length - 1 <= index) {
      remove(paths[index]);
      return;
    }
    final p = paths[index];
    if (p.isEmpty) {
      return;
    }
    if (!containsKey(p) ||
        this[p] == null ||
        this[p] is! Map<String, dynamic>) {
      return;
    }
    (this[p] as Map<String, dynamic>)._deleteFromPathInternal(paths, index + 1);
  }
}
