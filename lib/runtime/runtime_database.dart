part of model_notifier;

/// Runtime database.
class RuntimeDatabase {
  const RuntimeDatabase._();
  // ignore: prefer_final_fields
  static _LocalStore _db = _LocalStore();
  // ignore: prefer_final_fields
  static List<String> _registeredPath = [];

  /// Register new mock [data].
  static void registerMockData(Map<String, DynamicMap> data) {
    if (data.isEmpty) {
      return;
    }
    for (final tmp in data.entries) {
      if (_registeredPath.contains(tmp.key)) {
        continue;
      }
      _registeredPath.add(tmp.key);
      _db.addMockDocument(tmp.key, tmp.value);
    }
  }
}
