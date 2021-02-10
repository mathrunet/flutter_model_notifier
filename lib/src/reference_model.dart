part of model_notifier;

abstract class ReferenceModel<T> extends ValueModel<T> {
  ReferenceModel(this.ref, T initialValue) : super(initialValue) {
    final futureOr = build(ref);
    if (futureOr is Future<T>) {
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

  void _handledOnUpdated(T newValue) {
    value = newValue;
  }

  FutureOr<T> build(ProviderReference ref);
}
