part of model_notifier;

class _RuntimeDatabase {
  const _RuntimeDatabase();

  static DynamicMap get _root {
    return __root ??= {};
  }

  static DynamicMap? __root;
  static final Map<String, Set<RuntimeCollectionModel>> _parentList = {};

  static void _registerParent(RuntimeCollectionModel collection) {
    final path = collection.path.trimQuery();
    if (_parentList.containsKey(path)) {
      _parentList[path]?.add(collection);
    } else {
      _parentList[path] = {collection};
    }
  }

  static void _unregisterParent(RuntimeCollectionModel collection) {
    final path = collection.path.trimQuery();
    _parentList[path]?.remove(collection);
  }

  static void _addChild(RuntimeDocumentModel document) {
    final path = document.path.trimQuery().parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._addChildInternal(document));
  }

  static void _removeChild(RuntimeDocumentModel document) {
    final path = document.path.trimQuery().parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._removeChildInternal(document));
  }

  static void _notifyChildChanges(RuntimeDocumentModel document) {
    final path = document.path.trimQuery().parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._notifyChildChanges(document));
  }
}
