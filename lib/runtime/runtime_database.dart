part of model_notifier;

class _RuntimeDatabase {
  const _RuntimeDatabase();

  static final Map<String, Set<RuntimeCollectionModel>> _parentList = {};

  static void _registerParent(RuntimeCollectionModel collection) {
    final path = collection.path;
    if (_parentList.containsKey(path)) {
      _parentList[path]?.add(collection);
    } else {
      _parentList[path] = {collection};
    }
  }

  static void _unregisterParent(RuntimeCollectionModel collection) {
    final path = collection.path;
    _parentList[path]?.remove(collection);
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
