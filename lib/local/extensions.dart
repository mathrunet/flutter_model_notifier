part of model_notifier;

/// Map extension methods.
extension _LocalStringMapExtensions on Map<String, dynamic> {
  /// Reads data from a tree-structured map using paths.
  ///
  /// If there is no data, null is returned.
  ///
  /// [path]: The data path to read.
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

  /// Writes data to the tree structure map.
  ///
  /// A map will be created even if there is no intermediate tree.
  ///
  /// [path]: The path of data to write.
  /// [value]: The data to write.
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

  /// Deletes the data of the specified path from the tree structure data.
  ///
  /// All data under that path will be deleted.
  ///
  /// [path]: The path of data to delete.
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
