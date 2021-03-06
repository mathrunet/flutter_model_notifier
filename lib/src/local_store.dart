part of model_notifier;

class _LocalStore {
  _LocalStore({this.onInitialize, this.onLoad, this.onSaved, this.onDeleted});
  // ignore: prefer_final_fields
  DynamicMap _data = {};
  final Future<void> Function()? onInitialize;
  final Future<void> Function()? onSaved;
  final Future<void> Function()? onLoad;
  final Future<void> Function()? onDeleted;
  final Map<String, Set<_LocalStoreDocumentQuery>> _documentListeners = {};
  final Map<String, Set<_LocalStoreCollectionQuery>> _collectionListeners = {};

  bool get isInitialized => _isInitialized;
  bool _isInitialized = false;
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }
    await onInitialize?.call();
    _isInitialized = true;
  }

  void addDocumentListener(_LocalStoreDocumentQuery query) {
    final trimPath = query.path.trimQuery().trimString("/");
    if (_documentListeners.containsKey(trimPath)) {
      final listener = _documentListeners[trimPath]!;
      if (listener.contains(query)) {
        return;
      }
      listener.add(query);
    } else {
      _documentListeners[trimPath] = {query};
    }
  }

  void removeDocumentListener(_LocalStoreDocumentQuery? query) {
    if (query == null) {
      return;
    }
    final trimPath = query.path.trimQuery().trimString("/");
    if (_documentListeners.containsKey(trimPath)) {
      _documentListeners[trimPath]!.remove(query);
    }
  }

  void addCollectionListener(_LocalStoreCollectionQuery query) {
    final trimPath = query.path.trimQuery().trimString("/");
    if (_collectionListeners.containsKey(trimPath)) {
      final listener = _collectionListeners[trimPath]!;
      if (listener.contains(query)) {
        return;
      }
      listener.add(query);
    } else {
      _collectionListeners[trimPath] = {query};
    }
  }

  void removeCollectionListener(_LocalStoreCollectionQuery? query) {
    if (query == null) {
      return;
    }
    final trimPath = query.path.trimQuery().trimString("/");
    if (_collectionListeners.containsKey(trimPath)) {
      _collectionListeners[trimPath]!.remove(query);
    }
  }

  Future<DynamicMap?> loadDocument(_LocalStoreDocumentQuery query) async {
    await initialize();
    await onLoad?.call();
    final trimPath = query.path.trimQuery().trimString("/");
    final paths = trimPath.split("/");
    if (paths.isEmpty) {
      return null;
    }
    final value = _data._readFromPath(paths, 0);
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  Future<Map<String, DynamicMap>?> loadCollection(
      _LocalStoreCollectionQuery query) async {
    await initialize();
    await onLoad?.call();
    final trimPath = query.path.trimQuery().trimString("/");
    final paths = trimPath.split("/");
    if (paths.isEmpty) {
      return null;
    }
    final value = _data._readFromPath(paths, 0);
    if (value is! DynamicMap) {
      return null;
    }
    final entries = value.toList(
      (key, value) {
        if (value is! Map) {
          return null;
        }
        return MapEntry(
          key,
          Map<String, dynamic>.from(value),
        );
      },
    ).removeEmpty();
    if (query.filter != null) {
      entries.removeWhere((element) => !query.filter!(element.value));
    }
    return Map<String, DynamicMap>.fromEntries(entries);
  }

  void addMockDocument(String path, DynamicMap value) {
    if (path.isEmpty || value.isEmpty) {
      return;
    }
    final paths = path.trimQuery().trimString("/").split("/");
    if (paths.isEmpty) {
      return;
    }
    _data._writeToPath(paths, 0, Map.from(value));
  }

  Future<void> saveDocument(
      _LocalStoreDocumentQuery query, DynamicMap value) async {
    await initialize();
    final trimPath = query.path.trimQuery().trimString("/");
    final paths = trimPath.split("/");
    if (paths.isEmpty) {
      return;
    }
    _data._writeToPath(paths, 0, value);
    notifyDocuments(
      trimPath,
      paths.last,
      value,
      _LocalStoreDocumentUpdateStatus.addOrModified,
      query,
    );
    await onSaved?.call();
  }

  Future<void> deleteDocument(_LocalStoreDocumentQuery query) async {
    await initialize();
    final trimPath = query.path.trimQuery().trimString("/");
    final paths = trimPath.split("/");
    if (paths.isEmpty) {
      return;
    }
    _data._deleteFromPath(paths, 0);
    notifyDocuments(
      trimPath,
      paths.last,
      const {},
      _LocalStoreDocumentUpdateStatus.deleted,
      query,
    );
    await onDeleted?.call();
  }

  void notifyDocuments(
    String path,
    String key,
    DynamicMap value,
    _LocalStoreDocumentUpdateStatus status,
    _LocalStoreDocumentQuery query,
  ) {
    final collectionPath = path.parentPath();
    if (_documentListeners.containsKey(path)) {
      _documentListeners[path]?.forEach(
        (element) => element.callback(
          _LocalStoreDocumentUpdate(
            path: path,
            id: key,
            status: status,
            value: Map.from(value),
            origin: query.origin,
          ),
        ),
      );
    }
    if (_collectionListeners.containsKey(collectionPath)) {
      _collectionListeners[collectionPath]?.forEach(
        (element) => element.callback(
          _LocalStoreDocumentUpdate(
            path: path,
            id: key,
            status: status,
            value: Map.from(value),
            origin: query.origin,
          ),
        ),
      );
    }
  }
}

enum _LocalStoreDocumentUpdateStatus {
  addOrModified,
  deleted,
}

@immutable
class _LocalStoreDocumentUpdate {
  const _LocalStoreDocumentUpdate({
    required this.path,
    required this.id,
    required this.status,
    required this.value,
    required this.origin,
  });
  final String path;
  final String id;
  final Object origin;
  final _LocalStoreDocumentUpdateStatus status;
  final DynamicMap value;
}

@immutable
class _LocalStoreDocumentQuery {
  const _LocalStoreDocumentQuery({
    required this.path,
    required this.callback,
    required this.origin,
  });
  final String path;
  final Object origin;
  final void Function(_LocalStoreDocumentUpdate update) callback;
}

@immutable
class _LocalStoreCollectionQuery {
  const _LocalStoreCollectionQuery({
    required this.path,
    required this.callback,
    required this.origin,
    this.filter,
  });
  final String path;
  final Object origin;
  final void Function(_LocalStoreDocumentUpdate update) callback;
  final bool Function(DynamicMap update)? filter;
}

extension _LocalStoreDynamicMapExtensions on Map {
  dynamic _readFromPath(List<String> paths, int index) {
    if (paths.length <= index) {
      return this;
    }
    final p = paths[index];
    if (p.isEmpty) {
      return null;
    }
    final val = this[p];
    if (val is Map) {
      return val._readFromPath(paths, index + 1);
    }
    return val;
  }

  void _writeToPath(List<String> paths, int index, dynamic value) {
    final p = paths[index];
    if (p.isEmpty) {
      return;
    }
    if (paths.length - 1 <= index) {
      remove(p);
      this[p] = value;
      return;
    }
    final val = this[p];
    if (val is! Map) {
      final val = this[p] = <String, dynamic>{};
      val._writeToPath(paths, index + 1, value);
    } else {
      val._writeToPath(paths, index + 1, value);
    }
  }

  void _deleteFromPath(List<String> paths, int index) {
    final p = paths[index];
    if (p.isEmpty) {
      return;
    }
    if (paths.length - 1 <= index) {
      remove(p);
      return;
    }
    final val = this[p];
    if (val is! Map) {
      return;
    }
    val._deleteFromPath(paths, index + 1);
  }
}
