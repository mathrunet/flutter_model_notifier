part of model_notifier;

class _RuntimeDatabase {
  const _RuntimeDatabase();

  static final Map<String, Set<RuntimeCollectionModel>> _parentList = {};

  static void _registerParent(RuntimeCollectionModel collection) {
    final path = _path(collection.path);
    if (_parentList.containsKey(path)) {
      _parentList[path]?.add(collection);
    } else {
      _parentList[path] = {collection};
    }
  }

  static void _unregisterParent(RuntimeCollectionModel collection) {
    final path = _path(collection.path);
    _parentList[path]?.remove(collection);
  }

  static String _path(String path) {
    if (path.contains("?")) {
      return path.split("?").first;
    } else {
      return path;
    }
  }

  static RuntimeDocumentModel? _fetchChild(String path) {
    final parentPath = path.parentPath();
    final uid = path.last();
    if (!_parentList.containsKey(parentPath)) {
      return null;
    }
    return _parentList[parentPath]?.fold<RuntimeDocumentModel?>(null,
        (val, child) {
      if (val != null) {
        return val;
      }
      return child._fetchChildInternal(uid);
    });
  }

  static void _addChild(RuntimeDocumentModel document) {
    final path = document.path.parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._addChildInternal(document));
  }

  static void _removeChild(RuntimeDocumentModel document) {
    final path = document.path.parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._removeChildInternal(document));
  }
}
