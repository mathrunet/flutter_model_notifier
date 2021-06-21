part of model_notifier;

/// Runtime database.
class RuntimeDatabase {
  const RuntimeDatabase._();
  // ignore: prefer_final_fields
  static _LocalStore _db = _LocalStore();

  /// Register new mock [data].
  static void registerMockData(Map<String, DynamicMap> data) {
    if (data.isEmpty) {
      return;
    }
    for (final tmp in data.entries) {
      _db.addMockDocument(tmp.key, tmp.value);
    }
  }
}
