part of model_notifier;

/// Local database.
class LocalDatabase {
  const LocalDatabase._();
  // ignore: prefer_final_fields
  static _LocalStore _db = _LocalStore(
    onInitialize: () async {
      await Prefs.initialize();
      final text = Prefs.getString("local://".toSHA1());
      if (text.isNotEmpty) {
        _db._data = jsonDecodeAsMap(text);
      }
    },
    onSaved: () async {
      final json = jsonEncode(_db._data);
      Prefs.set("local://".toSHA1(), json);
    },
  );
}
