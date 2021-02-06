part of model_notifier;

abstract class ReferenceListModel<T extends Listenable> extends ListNotifier<T>
    implements Model<T> {
  ReferenceListModel(this.ref) : super() {
    final futureOr = build(ref);
    if (futureOr is Future<List<T>>) {
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

  void _handledOnUpdated(List<T> newList) {
    if (_equals(newList)) {
      return;
    }
    clear();
    addAll(newList);
  }

  bool _equals(List<T> newList) {
    if (length != newList.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != newList[i]) {
        return false;
      }
    }
    return true;
  }

  FutureOr<List<T>> build(ProviderReference ref);
}
