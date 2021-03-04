part of model_notifier;

class _LocalDatabase {
  _LocalDatabase._();

  /// True if initialization has been completed.
  static bool get isInitialized => Prefs.isInitialized;
  static Future initialize() async {
    if (isInitialized) {
      return;
    }
    await Prefs.initialize();
  }

  static Map<String, dynamic> get _root {
    if (!isInitialized) {
      debugPrint(
          "It has not been initialized. Please execute [initialize()] to initialize it.");
      return const {};
    }
    if (__root == null) {
      final text = Prefs.getString("local://".toSHA1());
      if (text.isEmpty) {
        __root = {};
      } else {
        __root = jsonDecodeAsMap(text);
      }
    }
    return __root ?? const {};
  }

  static Map<String, dynamic>? __root;
  static final Map<String, Set<LocalCollectionModel>> _parentList = {};

  static void _save() {
    if (!isInitialized) {
      debugPrint(
          "It has not been initialized. Please execute [initialize()] to initialize it.");
      return;
    }
    final json = jsonEncode(_root);
    Prefs.set("local://".toSHA1(), json);
  }

  static void _registerParent(LocalCollectionModel collection) {
    final path = collection.path;
    if (_parentList.containsKey(path)) {
      _parentList[path]?.add(collection);
    } else {
      _parentList[path] = {collection};
    }
  }

  static void _addChild(LocalDocumentModel document) {
    final path = document.path.parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    _parentList[path]
        ?.forEach((element) => element._addChildInternal(document));
  }

  static void _removeChild(LocalDocumentModel document) {
    final path = document.path.parentPath();
    if (!_parentList.containsKey(path)) {
      return;
    }
    for (final element in _parentList[path] ?? const <LocalCollectionModel>{}) {
      element._removeChildInternal(document);
    }
  }

  // static void _notifyChildChanges(LocalDocumentModel document) {
  //   final path = document.path.parentPath();
  //   if (!_parentList.containsKey(path)) {
  //     return;
  //   }
  //   for (final element in _parentList[path]!) {
  //     element._notifyChildChanges();
  //   }
  // }

  static void _unregisterParent(LocalCollectionModel collection) {
    final path = collection.path;
    _parentList[path]?.remove(collection);
  }
}
