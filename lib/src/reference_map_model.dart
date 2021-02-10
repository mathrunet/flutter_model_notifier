part of model_notifier;

abstract class ReferenceMapModel<T> extends MapModel<T> {
  ReferenceMapModel(this.ref) : super() {
    final futureOr = build(ref);
    if (futureOr is Future<Map<String, T>>) {
      futureOr.then(_handledOnUpdated);
    } else {
      _handledOnUpdated(futureOr);
    }
  }
  final ProviderReference ref;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode;

  void _handledOnUpdated(Map<String, T> newMap) {
    if (_equals(newMap)) {
      return;
    }
    clear();
    addAll(newMap);
  }

  bool _equals(Map<String, T> newMap) {
    if (length != newMap.length) {
      return false;
    }
    for (final key in keys) {
      if (!newMap.containsKey(key) || newMap[key] != this[key]) {
        return false;
      }
    }
    return true;
  }

  FutureOr<Map<String, T>> build(ProviderReference ref);
}
